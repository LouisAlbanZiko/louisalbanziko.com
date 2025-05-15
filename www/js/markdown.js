function outerHeight(element) {
	let height = element.offsetHeight;
	height += parseInt(window.getComputedStyle(element).getPropertyValue('margin-top'));
	height += parseInt(window.getComputedStyle(element).getPropertyValue('margin-bottom'));
	return height;
}

document.addEventListener('DOMContentLoaded', () => {
	const pe_header = document.querySelector('pe-header');
	const pe_title = document.querySelector('pe-title');
	const markdown_height = window.innerHeight - outerHeight(pe_header) - outerHeight(pe_title);
	console.log(`markdown_height=${markdown_height}`);
	document.querySelector('markdown').style.height = `${markdown_height}px`;

	document.querySelectorAll('markdown code').forEach((element) => {
		const parentElement = element.parentElement;
		if (parentElement.tagName.toLowerCase() !== 'pre') {
			element.onclick = (event) => {
				navigator.clipboard.writeText(event.srcElement.textContent);
				//alert('Copied ' + event.srcElement.textContent);
			};
		} else {
			//const text = element.textContent.substring(0, element.textContent.length - 1);
			//var new_text = "";
			//var line_count = 0;
			//console.log(`text='${text}'`);
			//text.split('\n').forEach((line) => {
			//	console.log(`${line_count}  '${line}'\n`);
			//	new_text += `${line_count}  ${line}\n`;
			//	line_count += 1;
			//});
			//element.textContent = new_text;
			const img = document.createElement('img');
			img.src = '/img/copy.svg';
			img.style.width = '1.2rem';
			img.style.height = '1.2rem';
			img.style.padding = '0.2rem';
			img.style['border-radius'] = '0.2rem';
			img.onclick = (event) => {
				navigator.clipboard.writeText(element.textContent);
			};
			parentElement.appendChild(img);
		}
	});
	const headings = [];
	document.querySelectorAll('markdown h1').forEach((element) => {
		element.id = element.textContent;
		headings.push(element.textContent);
	});
	const list = document.createElement('ul');
	document.getElementById('md-navigation').appendChild(list);
	headings.forEach((heading) => {

		const link = document.createElement('a');
		link.href = `#${heading}`;
		link.textContent = heading;
		const li = document.createElement('li');
		li.appendChild(link);
		list.appendChild(li);
	});
});
