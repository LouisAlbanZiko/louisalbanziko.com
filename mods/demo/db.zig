const std = @import("std");
const server = @import("server");

const Database = server.Database;

const Self = struct {
    gpa: std.mem.Allocator,
    db: *Database,
};
var self: Self = undefined;

pub fn init(gpa: std.mem.Allocator, db: *Database) !void {
    self.gpa = gpa;
    self.db = db;

    try db.conn.exec("CREATE TABLE IF NOT EXISTS profile(name TEXT NOT NULL UNIQUE, password_hash BLOB NOT NULL, user_id INTEGER NOT NULL UNIQUE, FOREIGN KEY(user_id) REFERENCES user(id))");
}

pub fn deinit() void {}

const argon2 = std.crypto.pwhash.argon2;
const PW_PARAMS = argon2.Params{ .t = 2, .m = 16_000, .p = 1 };

pub fn new_profile(name: [:0]const u8, password: [:0]const u8) !Database.UserID {
    const user_id = try self.db.new_user();

    var password_hash_buffer: [1024]u8 = undefined;
    const password_hash = try argon2.strHash(password, .{ .allocator = self.gpa, .params = PW_PARAMS }, &password_hash_buffer);

    var stmt = try self.db.conn.prepare_v2("INSERT INTO profile(name, password_hash, user_id) VALUES(?,?,?)");
    defer stmt.finalize();

    try stmt.bind_text(0, name);
    try stmt.bind_blob(1, password_hash);
    try stmt.bind_i64(2, @bitCast(user_id));

    _ = try stmt.step();

    return user_id;
}

pub fn check_login(name: [:0]const u8, password: [:0]const u8) !?Database.UserID {
    var stmt = try self.db.conn.prepare_v2("SELECT user_id, password_hash FROM profile WHERE name = ?");
    defer stmt.finalize();

    try stmt.bind_text(0, name);

    if (try stmt.step() == .ROW) {
        const db_user_id = stmt.column_i64(0);
        const db_password_hash = try stmt.column_blob(1);

        if (argon2.strVerify(db_password_hash, password, .{ .allocator = self.gpa })) {
            const user_id: Database.UserID = @bitCast(db_user_id);
            return user_id;
        } else |_| {
            return null;
        }
    } else {
        return null;
    }
}
