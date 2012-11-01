function thingspotterImageSpotter() {

    this.imageArray = new Array();
    this.imageCount = 0;
	if (!serverURL)
		serverURL = "http://www.thingspotter.com"

	// Helper method - find X;Y of image
    this.getImageLocation = function(a) {
        var c = a.offsetLeft;
        var b = a.offsetTop;
        while (a.offsetParent) {
            c = c + a.offsetParent.offsetLeft;
            b = b + a.offsetParent.offsetTop;
            if (a != document.getElementsByTagName("body")[0]) {
                a = a.offsetParent
            }
            else {
                break
            }
        }
        return [c, b]
    };

	// Close IFrame cross domain (StackOverflow)
	/*
	this.checkIfCloseIFrame = function() {
		alert('checkIfCloseIFrame: ' + window.ts_iframe.location.href);
	    if (window.ts_iframe && window.ts_iframe.location.hash == "#close_iframe") {
			alert('Time to close!');
	        var tsIframe = document.getElementById("ts_iframe");
	        tsIframe.parentNode.removeChild(someIframe);
	    }
	    else {
	        setTimeout(self.checkIfCloseIFrame, 3000)
	    }
	}
	*/

	// Send Thing to Thingspotter
    this.spotProduct = function(c, mode) {
        //alert('spotProduct: ' + c + ', ' + mode);
		var pageURL = serverURL + "/spots/new?imagespotter=true" + "&mode=" + mode + "&url=" + escape(document.location.href) + "&image=" + encodeURIComponent(this.imageArray[c].src);
		// document.location.href = pageURL;
		window.open(pageURL, 'ts_window', 'left=0,top=0,width=300,height=640,titlebar=no,location=no,menubar=no,toolbar=no,status=no,scrollbars=yes,resizable=yes', false);
		
		// Create IFrame
		/*
		var tsIframeObj = document.createElement("iframe");
        tsIframeObj.setAttribute("id", "ts_iframe");
        tsIframeObj.setAttribute("name", "ts_iframe");
        // tsIframeObj.setAttribute("marginheight", "0");
        // tsIframeObj.setAttribute("marginwidth", "0");
        // tsIframeObj.setAttribute("frameborder", "no");
        //tsIframeObj.setAttribute("scrolling", "no");
        document.getElementsByTagName("body")[0].appendChild(tsIframeObj);
		var tsIframe = parent.document.getElementById("ts_iframe");
		tsIframe.width = 300;
		tsIframe.height = 550;
		tsIframe.style.position = "absolute";
		tsIframe.style.right = "10px";
		tsIframe.style.top = "10px";
		tsIframe.style.zIndex = 100;
		tsIframe.style.border = "1px solid #999";
		//tsIframe.style.padding = "8px";
		tsIframe.src = pageURL;
		setTimeout(this.checkIfCloseIFrame, 1000);
		*/
		
/*
        // Post form to server
		var b = document.createElement("script");
        b.setAttribute("type", "text/javascript");
        b.setAttribute("method", "post");
        b.setAttribute("src", pageURL);
        document.getElementsByTagName("head")[0].appendChild(b);

        document.getElementById("thingspotter_instruction_" + c).innerHTML = "Spotted!<br/><br/><a style='color:#FFFFFF;font-size:10pt;' href='" + serverURL + "?id=" + serId + "' >View on Thingspotter.</a>";
        document.getElementById("thingspotter_instruction_" + c).style.display = "block";
        
		// Loop through all identified images in array
		for (var a = 0; a < this.imageCount; a++) {
            if (a != c) {
                document.getElementById("thingspotter_highlight_" + a).style.display = "none"
            }
        }

		// Hide after 3 seconds
		var e = this;
        setTimeout(function() {
            e.stopImageSpotter()
        }, 3000)

*/
		
    };

	// Mark up all images on page. Called automatically when script loads.
    this.startImageSpotter = function() {
		// Insert stylesheet if not already there
        if (!document.getElementById("thingspotter_imagespotter")) {
            var j = document.createElement("link");
            j.setAttribute("href", serverURL+"/stylesheets/imagespotter.css");
            j.setAttribute("rel", "stylesheet");
            j.setAttribute("type", "text/css");
            var a = document.createElement("div");
            a.id = "thingspotter_imagespotter";
            document.getElementsByTagName("head")[0].appendChild(j);
            document.getElementsByTagName("body")[0].appendChild(a)
        }
		// Loop through all images on page
        var c = document.getElementsByTagName("img");
        for (var b = 0; b < c.length; b++) {
            var d = c[b];
			// If image size >= 100 pixels
            if (d.offsetWidth >= 100 && d.offsetHeight >= 100) {
                this.imageArray[this.imageCount] = d;
                var i = this.getImageLocation(d)[0];
                var g = this.getImageLocation(d)[1];
                var f = d.offsetWidth;
                var e = d.offsetHeight;
                var h = document.createElement("div");
                h.id = "thingspotter_highlight_" + this.imageCount;
                h.setAttribute("class", "thingspotter_image");
                //h.setAttribute("onclick", "tsInstance.spotProduct(" + this.imageCount + ", 'mode');");
                h.style.left = i + "px";
                h.style.top = g + "px";
                h.style.height = (e - 40) + "px";
                h.style.width = (f - 40) + "px";
                h.style.display = "block";
				var spotLabel = 'Spot this Thing!';
				var spotStyle = "color:#FFFFFF; font-family:Helvetica,Arial,sans-serif; font-size:11pt; margin-top:" + ((e - 100) / 2) + "px;";
                //h.innerHTML = "<div id='thingspotter_instruction_" + this.imageCount + "' style='" + spotStyle + "'>" + spotLabel + "</div>";
				h.innerHTML = '<div id="iconsetXX" class="ts_iconset"><a class="ts_icon ts_share" href="" id="shareXX" onclick="tsInstance.spotProduct(' + this.imageCount + ', \'add\');" title="Like and share this thing"></a><a class="ts_icon ts_want" href="" id="wantXX" onclick="tsInstance.spotProduct(' + this.imageCount + ', \'want\');" title="You want this thing?"></a><a class="ts_icon ts_own" href="" id="ownXX" onclick="tsInstance.spotProduct(' + this.imageCount + ', \'own\');" title="You own this thing?"></a><a class="ts_icon ts_recommend" href="" id="recommendXX" onclick="tsInstance.spotProduct(' + this.imageCount + ', \'recommend\');" title="Recommend this thing to someone"></a></div>';
				document.getElementById("thingspotter_imagespotter").appendChild(h);
                this.imageCount++
            }
        }
		if (this.imageCount == 0) {
			// No images found
			alert('Sorry, but Thingspotter could not find any images on this web page that are at least 100*100 pixels in size.');
		}
    };

	// Called after X seconds timeout in spotProduct()
    this.stopImageSpotter = function() {
        var b = document.getElementById("thingspotter_imagespotter");
		// Loop through all identified images in array
        for (var a = 0; a < this.imageCount; a++) {
            var c = document.getElementById("thingspotter_highlight_" + a);
            b.removeChild(c)
        }
		// Wait 1 second, then consider ImageSpotter not running anymore
        setTimeout(function() {
            this.imageCount = 0;
            window.isImageSpotterRunning = false;
        }, 1000)
    };

    this.startImageSpotter();
}

// Create single instance of thingspotterImageSpotter
if (!window.isImageSpotterRunning) {
    window.isImageSpotterRunning = true;
    var tsInstance = new thingspotterImageSpotter();
};

// Close the iFrame
function closeImageSpotterFrame() {
	// http://stackoverflow.com/questions/2182027/close-iframe-cross-domain
	// http://www.tagneto.org/blogcode/xframe/ui.html
	//window.parent.location = window.parent.location;
	window.close();
	//window.location = "#close_iframe";
	//alert(window.location);
	//var tsIframe = document.getElementById('ts_iframe');
	//alert("parent.location.href: " + parent.location.href);
	//alert("window.parent: " + window.parent); // OK
	//alert("window.parent.document: " + window.parent.document); // undefined
	//alert("window.opener: " + window.opener); // null
	//alert("window.opener.document: " + window.opener.document); // error, since window.opener == null
	//alert("document.parentNode: " + document.parentNode); // null
	//alert("window.parent.ts_iframe: " + window.parent.ts_iframe); // OK
	//alert("window.parent.ts_iframe.document: " + window.parent.ts_iframe.document); // OK
	//alert("window.parent.ts_iframe.document.parentNode: " + window.parent.ts_iframe.document.parentNode); // null
	//alert("2: " + window.parent.document);
	//dumpProperties(window.opener.parent);
	//alert("3: " + tsIframe);
	//window.opener.close();
	/*
	var tsParent = tsIframe.parentNode;
	tsParent.removeChild(tsIframe);
	*/
}