// from http://doc.infosnel.nl/javascript_trim.html
function trim(s) {
	var l=0; var r=s.length -1;
	while(l < s.length && s[l] == ' ')
	{	l++; }
	while(r > l && s[r] == ' ')
	{	r-=1;	}
	return s.substring(l, r+1);
}

// Usage: if (isMouseLeaveOrEnter(event, this)) {...}; // From http://dynamic-tools.net/toolbox/isMouseLeaveOrEnter/
function isMouseLeaveOrEnter(e, handler) {
	var newTarget = e.relatedTarget ? e.relatedTarget : (e.type == 'mouseout' ? e.toElement : e.fromElement);
	while (newTarget && newTarget != handler) newTarget = newTarget.parentNode;
	//throw("isMouseLeaveOrEnter: " + e.type + ", " + newTarget + " = " + (newTarget != handler));
	return (newTarget != null && newTarget != handler);
}

function hideAllIconSets() {
	$$('.ts_iconset').each(function(element){
		element.hide();
	});
}

function dumpProperties(obj) {
	var strtemp = "";
	for(var key in obj){
		strtemp += key + ", "
	}
	throw(strtemp);
}

function toggleOptionalSection(reference, focusField) {
	section = $('section_' + reference);
	header = $('section_' + reference + '_header');
	if (header.classNames() == 'optional_section_header') {
		// Open
		Effect.SlideDown('section_' + reference, { duration: 0.3 });
		header.removeClassName('optional_section_header');
		header.addClassName('optional_section_header_open');
		if (focusField != null)
			$(focusField).focus();
	}
	else {
		// Close
		Effect.SlideUp('section_' + reference, { duration: 0.3 });
		header.removeClassName('optional_section_header_open');
		header.addClassName('optional_section_header');
	}
}

function imageToggle(elementId, hiddenFieldId) {
	if ($(hiddenFieldId).value == 'true') {
		// Was true, become false
		$(hiddenFieldId).value = 'false';
		$(elementId).removeClassName(elementId + '_on');
		$(elementId).addClassName(elementId + '_off');
	}
	else {
		// Was false, become true
		$(hiddenFieldId).value = 'true';
		$(elementId).removeClassName(elementId + '_off');
		$(elementId).addClassName(elementId + '_on');
	}
}