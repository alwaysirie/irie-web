// Mobile

function loadPage(){
	setFeaduredDeal();
	getDealsData();
	updateMyDeals();
	loadMapData();
	setPayments();
	if (localStorage.getItem('user_id') != null){
		refreshUserData();
	}
}

// Data Handling

function getDealsData(){
	$.getJSON("/mobile/getDealsData.json", function(data) {
		localStorage.setItem('dealData', '{"deals" : ' + JSON.stringify(data) + '}');

	}, 'json').complete(function(){loadDealData('', '');})
}

function setFeaduredDeal(){
	$.getJSON("/mobile/setFeaduredDeal.json", function(deal) {
		html = '<tr><td class="featuredDealWrapperTop" colspan="3"><h1>Todays Featured Deal:</h1></td></tr><tr><td class="featuredDealWrapper" colspan="3"><div id="homeFeaturedInfo" style="background-image:url(\'/images/' + deal.home + '\');"><h2>' + deal.company_name + '</h2><h3>' + deal.headline + '</h3></div></td></tr><tr class="homeFeaturedPricing"><td style="homeFeaturedPrice">Cost: $' + parseFloat(deal.cost).toFixed(2) + '</td><td style="homeFeaturedPrice">Value: $' + parseFloat(deal.retail).toFixed(2) + '</td><td onclick="getDealData(\'' + deal.id + '\')"><img src="/assets/mobile_buyNow.png" width="81"></td></tr>';
		document.querySelector('.dealInsertWrapper').innerHTML = html;
		localStorage.setItem('featuredDealData', JSON.stringify(deal));
	}, 'json').complete(function(){
	
	})

}

function updateFilter(){
	loadDealData(document.querySelector('#priceFilter').value, document.querySelector('#areaFilter').value);
}

function loadDealData(max_price, location){
	document.querySelector('#dealListWrapper').innerHTML = '';
	html = '';
	$.each( jQuery.parseJSON(localStorage.getItem('dealData')).deals, function(i, deal) {
		if ((max_price == '' || parseFloat(deal.cost) <= parseFloat(max_price)) && (location == '' || location.toString() == deal.area_id.toString())){
			html += '<div style="padding:10px 10px;border-bottom:1px solid #999999;background-color:#f1f1f1;"><table class="dealPageDealListing"><tr onclick="getDealData(\'' + deal.id.toString() + '\')"><td class="dealPageListingLeft" style="background-image:url(\'/images/' + deal.home + '\');"><h1>' + deal.company_name + '</h1><strong>' + deal.headline + '</strong></td><td class="dealPageListingRight"><strong>Price:</strong> $' + deal.cost.toFixed(2) + '<br><br> <strong>Value:</strong> $' + deal.retail.toFixed(2) + '</td></tr></table></div>';
		}
	});
	document.querySelector('#dealListWrapper').innerHTML = html;
}

function loadMapData(){
	$.getJSON("/mobile/getDealMap.json", function(data) {
		mapData = data;
		markers = [];
		for (i=0;i<mapData.mapcache_locations.length;i++){
			deals = ''
			for (n=0;n<mapData.mapcache_locations[i].mapcache_deals.length;n++){
				deals += '<a href=\'\' onclick=getDealData(\'' + mapData.mapcache_locations[i].mapcache_deals[n].id + '\')>' + mapData.mapcache_locations[i].mapcache_deals[n].headline + '</a><br>';
			}
			content = '<b>' + mapData.mapcache_locations[i].company_name + '</b><br><em>Deals:</em><br>' + deals;
			marker = '{ "latitude": ' + mapData.mapcache_locations[i].lat + ', "longitude": ' + mapData.mapcache_locations[i].lng + ', "title":"' + mapData.mapcache_locations[i].lng + '", "content":"' + content + '" }';
			markers.push(marker);
		}
		localStorage.setItem('mapData', '{"markers" : [' + markers + ']}');
	}, 'json').error(function(){
		
	})
}

function updateMyDeals(){
	if (localStorage.getItem('user_id') != null){
		postData = {id: localStorage.getItem('user_id')};
		$.post("/mobile/updateMyDeals.json", postData, function(data) {
			formattedDeals = [];
			for (i=0;i<data.deals.length;i++){
				for (n=0;n<data.vouchers.length;n++){
					if (data.vouchers[n].deal_id == data.deals[i].id){
						dealinfo = '{"id": "' + data.vouchers[n].id + '","deal_id": "' + data.deals[i].id + '", "company_name": "' + data.deals[i].company_name + '", "headline": "' + data.deals[i].headline + '", "retail": "' + data.deals[i].retail + '", "description": "' + data.deals[i].description + '", "fine_print": "' + data.deals[i].fine_print + '"}';
						formattedDeals.push(dealinfo);
					}
				}
			}
			localStorage.setItem('myDeals', '{"deals": [' + formattedDeals + ']}');
		}, 'json').complete(function(){
			displayMyDeals();
		})
	}
}

function getDealData(id){
	if (localStorage.getItem('currentDealData') != null && jQuery.parseJSON(localStorage.getItem('currentDealData')).dealData.id == id){
		showCurrentDeal();
		$.mobile.changePage( "#ViewDealPage", { transition: "slide"} );
	}else{
		$.mobile.loading( 'show', {
			text: 'foo',
			icon: "arrow-r",
			textVisible: true,
			theme: 'z',
			html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>Loading Deal...</h2></span>"
		});
		postData = {id: id};
		$.post("/mobile/getDeal.json", postData, function(data) {
			localStorage.setItem('currentDealData', JSON.stringify(data));
			showCurrentDeal();
			$.mobile.changePage( "#ViewDealPage", { transition: "slide"} );
		}, 'json').error(function(){
			$.mobile.loading( 'show', {
				text: 'foo',
				icon: "arrow-r",
				textVisible: true,
				theme: 'z',
				html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>I apologize for this but I am unable to show you this deal</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
			});
		})
	}
}

function refreshUserData(){
	postData = {
		id: localStorage.getItem('user_id')
	};
	$.post("/mobile/refreshUserData.json", postData, function(data) {
		if (data.status == 'success'){
			localStorage.setItem('user_id', data.user_id);
			localStorage.setItem('name', data.name);
			localStorage.setItem('payments', '[' + data.cards + ']');
			setPayments();
		}else{
			
		}
	}, 'json')
}

// Login & Register

function registerAccount(){
	$.mobile.loading( 'show', {
		text: 'foo',
		icon: "arrow-r",
		textVisible: true,
		theme: 'z',
		html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>Registering Account...</h2></span>"
	});
	if (document.querySelector('#register_password').value != document.querySelector('#register_password_verify').value){
		$.mobile.loading('hide');
		return alert('Your passwords do not match')
	}
	postData = {
		first_name: document.querySelector('#register_first_name').value,
		last_name: document.querySelector('#register_last_name').value,
		email: document.querySelector('#register_email').value,
		password: document.querySelector('#register_password').value
	};
	$.post("/mobile/registerAccount.json", postData, function(data) {
		if (data.status == 'success'){
			localStorage.setItem('user_id', data.user_id);
			localStorage.setItem('name', data.name);
			localStorage.setItem('payments', '[' + data.cards + ']');
			$(".logoutButton").css("display","block");
			if (document.querySelector('#login_purchase').value == 'yes'){
				$.mobile.changePage( "#PurchaseDeal", { transition: "flip"} );
			}else{
				$.mobile.changePage( "#HomePage", { transition: "flip"} );
			}
		}else{
			$.mobile.loading( 'show', {
				text: 'foo',
				icon: "arrow-r",
				textVisible: true,
				theme: 'z',
				html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>Error<br>" + data.reason + "</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
			});
		}
	}, 'json').error(function(){
		$.mobile.loading( 'show', {
			text: 'foo',
			icon: "arrow-r",
			textVisible: true,
			theme: 'z',
			html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>I am having difficulties contacting the server at this time.</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
		});
	})
}

function tryToLogin(){
	$.mobile.loading( 'show', {
		text: 'foo',
		icon: "arrow-r",
		textVisible: true,
		theme: 'z',
		html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>Logging In...</h2></span>"
	});
	postData = {
		username: document.querySelector('#login_username').value,
		password: document.querySelector('#login_password').value
	};
	$.post("/mobile/login.json", postData, function(data) {
		if (data.status == 'success'){
			$(".logoutButton").css("display","block");
			localStorage.setItem('user_id', data.user_id);
			localStorage.setItem('name', data.name);
			localStorage.setItem('payments', '[' + data.cards + ']');
			afterLogin();
			if (document.querySelector('#login_purchase').value == 'yes'){
				$.mobile.changePage( "#PurchaseDeal", { transition: "flip", reverse: false,changeHash: false} );
			}else{
				$.mobile.changePage( "#HomePage", { transition: "flip"} );
			}
		}else{
			$.mobile.loading( 'show', {
				text: 'foo',
				icon: "arrow-r",
				textVisible: true,
				theme: 'z',
				html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>The Username or Password is incorrect.</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
			});
		}
	}, 'json').error(function(){
		$.mobile.loading( 'show', {
			text: 'foo',
			icon: "arrow-r",
			textVisible: true,
			theme: 'z',
			html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>I am having difficulties contacting the server at this time.</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
		});
	})
}

function afterLogin(){
	updateMyDeals();
	setPayments();
}

function setPayments(){
	payments = jQuery.parseJSON(localStorage.getItem('payments'));
	if (payments != null && payments.length > 0){
		html = '';
		$.each( payments, function(i, payment) {
			if (i==0){
				html += '<input name="ccgroup" type="radio" value="' + payment.id + '" checked="checked" onclick="purchaseDealSelectCC(\'existing\')" class="regular-radio" /> Card Ending ' + payment.last_four + '<br>';
			}else{
				html += '<input name="ccgroup" type="radio" value="' + payment.id + '" onclick="purchaseDealSelectCC(\'existing\')" class="regular-radio" /> Card Ending ' + payment.last_four + '<br>';
			}
		});
		html += '<input name="ccgroup" type="radio" value="new_card" onclick="purchaseDealSelectCC(\'new\')"> Use A New Credit Card<br>';
		document.querySelector('#paymentContainer').innerHTML = html;
		document.querySelector('#newCardLabel').style.display = 'block';
		if (payments.length >= 1){
			purchaseDealSelectCC('existing');
		}
	}
}

// View Changes

function showCurrentDeal(){
	data = jQuery.parseJSON(localStorage.getItem('currentDealData'));
	if (data != null){
		mapData = '';
		for (i=0;i<data.locations.length;i++){
			mapData += '<div id="locationBlockWrapper"><div id="locationBlockInfo"><strong> ' + data.locations[i].name   + '</strong><br>' + data.locations[i].address   + '<br>' + data.locations[i].city + ', '+ data.locations[i].state +' ' + data.locations[i].zip + '<br><strong>P:</strong> ' + data.locations[i].phone   + '<br><br><strong>Hours of Operation</strong><table style="width:100%;font-size:13px;"><tr><td><u>Sunday</u></td><td> ' + data.locations[i].sunday_open   + '  ' + data.locations[i].sunday_open_ampm   + ' -  ' + data.locations[i].sunday_close   + '  ' + data.locations[i].sunday_close_ampm   + '</td></tr><tr><td><u>Monday</u></td><td> ' + data.locations[i].monday_open   + '  ' + data.locations[i].monday_open_ampm   + ' -  ' + data.locations[i].monday_close   + '  ' + data.locations[i].monday_close_ampm   + '</td></tr><tr><td><u>Tuesday</u></td><td> ' + data.locations[i].tuesday_open   + '  ' + data.locations[i].tuesday_open_ampm   + ' -  ' + data.locations[i].tuesday_close   + '  ' + data.locations[i].tuesday_close_ampm   + '</td></tr><tr><td><u>Wednesday</u></td><td> ' + data.locations[i].wednesday_open   + '  ' + data.locations[i].wednesday_open_ampm   + ' -  ' + data.locations[i].wednesday_close   + '  ' + data.locations[i].wednesday_close_ampm   + '</td></tr><tr><td><u>Thursday</u></td><td> ' + data.locations[i].thursday_open   + '  ' + data.locations[i].thursday_open_ampm   + ' -  ' + data.locations[i].thursday_close   + '  ' + data.locations[i].thursday_close_ampm   + '</td></tr><tr><td><u>Friday</u></td><td> ' + data.locations[i].friday_open   + '  ' + data.locations[i].friday_open_ampm   + ' -  ' + data.locations[i].friday_close   + '  ' + data.locations[i].friday_close_ampm   + '</td></tr><tr><td><u>Saturday</u></td><td> ' + data.locations[i].saturday_open   + '  ' + data.locations[i].saturday_open_ampm   + ' -  ' + data.locations[i].saturday_close   + '  ' + data.locations[i].saturday_close_ampm   + '</td></tr></table></div></div>';
		}
		dealData = '<div id="dealPageInfoWrapper"><div id="dealHero" style="background-image:url(\'/images/' + data.dealData.hero + ' \');"><div id="dealHeadingTitle"></div><h1>' + data.dealData.headline + ' </h1><a onclick="purchaseDealPage()" style="text-decoration:none;"><div id="buyNowHero">Purchase This Deal</div></a></div><div id="dealNav"><div id="dealDescription" class="dealNavButton on" onclick="changeDealInfo(\'dealDescription\')">Deal Information</div><div id="dealFinePrint" class="dealNavButton" onclick="changeDealInfo(\'dealFinePrint\')">Fine Print</div><div id="dealMapsInfo" class="dealNavButton" onclick="changeDealInfo(\'dealMapsInfo\')">Locations</div><input type="hidden" value="' + data.dealData.id + ' " id="paramID"></div><div id="innerDealWrapper"><div id="dealDescriptionSection">' + data.dealData.description + ' </div><div id="dealFinePrintSection" style="display:none;">' + data.dealData.fine_print + ' </div><div id="dealMapsInfoSection" style="display:none;">' + mapData + '</div></div></div>';
		document.querySelector('#dealData').innerHTML = dealData;
		document.querySelector('.checkoutTotalsLeft').innerHTML = '<strong>Cost:</strong> $' + parseFloat(data.dealData.cost).toFixed(2) + '<br><strong>Retail Value:</strong> $' + parseFloat(data.dealData.retail).toFixed(2) + '';
		document.querySelector('.checkoutTotalsRight').innerHTML = '<h4>Total: $' + parseFloat(data.dealData.cost).toFixed(2) + '</h4>';
		document.querySelector('.purchaseDealHeadline').innerHTML = '<b>' + data.dealData.headline + '</b>';
		htmlqty = '';
		n = 1
		for (var i = 0; i < parseInt(data.dealData.max_per_customer); i++){
			htmlqty += '<option value="' + n + '">' + n + '</option>';
			n++;
		}
		document.querySelector('#deal_qty').innerHTML = htmlqty;
	}else{
		$.mobile.changePage( "#DealsPage", { transition: "fade"} );
	}
}

$('#ViewDealPage').live("pagecreate", function() {
	showCurrentDeal();
});

// My Deals

$('#MyDeals').live('pagecreate', function(){
	if (localStorage.getItem('user_id') == null){
		
		$.mobile.changePage( "#LoginPage", {transition: "flip", reverse: false,changeHash: false});
	}else{
		
	}
});

function displayMyDeals(){
	data = jQuery.parseJSON(localStorage.getItem('myDeals'));
	if (data != null){
		html = '';
		$.each( data.deals, function(i, deal) {
			html += '<tr class="dealTr"><td class="row"><b>' + deal.company_name + '</b><br>' + decodeURIComponent(deal.headline) + '</td><td class="row viewMyDeal"><a onclick="viewMyDeal(\'' + deal.id + '\')">View</a></td></tr>';
		});
		document.querySelector('#myDeals').innerHTML = html;
	}
}

function viewMyDeal(id){
	data = jQuery.parseJSON(localStorage.getItem('myDeals'));
	$.each( data.deals, function(i, deal) {
		if(deal.id.toString() == id.toString()){
			document.querySelector('#viewDealCompanyName').innerHTML = deal.company_name;
			document.querySelector('#viewDealHeadline').innerHTML = decodeURIComponent(deal.headline);
			document.querySelector('#viewDealValue').innerHTML = 'Value: $' + parseFloat(deal.retail).toFixed(2);
			document.querySelector('#viewDealDescription').innerHTML = decodeURIComponent(deal.description);
			document.querySelector('#viewDealFinePrint').innerHTML = decodeURIComponent(deal.fine_print);
			document.querySelector('#viewDealID').innerHTML = 'ID: ' + deal.id;
			document.querySelector("#barcode128h").innerHTML = code128(deal.id.toString());
		}
	});
	$.mobile.changePage( "#ViewMyDeal", { transition: "flip"} );
}

//

function purchaseDealPage(){
	if (localStorage.getItem('user_id') == null){
		document.querySelector('#login_purchase').value = 'yes';
		$.mobile.changePage( "#LoginPage", { transition: "flip", reverse: false, changeHash: false} );
	}else{
		//$.mobile.changePage( "#PurchaseDeal", { transition: "slide"} );
		$.mobile.changePage( "#PurchaseDeal", {transition: "slide", reverse: false,changeHash: false});
	}
}

function confirmPurchase(){
	postData = {
		id: jQuery.parseJSON(localStorage.getItem('currentDealData')).dealData.id,
		user_id: localStorage.getItem('user_id'),
		qty: document.querySelector('#deal_qty').value,
		ccgroup: $('input[name=ccgroup]:checked')[0].value,
		card_number: document.querySelector('#card_number').value,
		card_month: document.querySelector('#card_month').value,
		card_year: document.querySelector('#card_year').value,
		card_cvv: document.querySelector('#card_cvv').value,
		card_name: document.querySelector('#card_name').value,
		card_address: document.querySelector('#card_address').value,
		card_city: document.querySelector('#card_city').value,
		card_state: document.querySelector('#card_state').value,
		card_zip: document.querySelector('#card_zip').value,
		aff: localStorage.getItem('affiliate')
	};
	$.post("/mobile/confirmPurchase.json", postData, function(data) {
		if (data.status == 'success'){
			updateMyDeals();
			refreshUserData();
			$.mobile.loading( 'show', {
				text: 'foo',
				icon: "arrow-r",
				textVisible: true,
				theme: 'z',
				html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>Purchase Successfull!<br>You can view this voucher in the 'My Deals' section</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" );$.mobile.changePage( \"#MyDeals\", { transition: \"slide\"} );' style='padding:10px 20px;margin-top:10px;'></span>"
			});
		}else{
			$.mobile.loading( 'show', {
				text: 'foo',
				icon: "arrow-r",
				textVisible: true,
				theme: 'z',
				html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>" + data.reason + "</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
			});
		}
	}, 'json').error(function(){
		$.mobile.loading( 'show', {
			text: 'foo',
			icon: "arrow-r",
			textVisible: true,
			theme: 'z',
			html: "<span class='ui-bar ui-overlay-c ui-corner-all' style='background-color:#000000;padding:40px 10px;text-align:center;'><h2 style='color:#ffffff;'>I am having difficulties contacting the server at this time.</h2><input type='button' value='ok' onclick='$.mobile.loading( \"hide\" )' style='padding:10px 20px;margin-top:10px;'></span>"
			
		});
	})
}


function changeDealInfo(section){
	if (section == 'dealBuyNow'){
		window.location = '/web/purchaseDeal/' + document.getElementById('paramID').value 
	}else{
		document.getElementById('dealDescriptionSection').style.display = 'none';
		document.getElementById('dealFinePrintSection').style.display = 'none';
		document.getElementById('dealMapsInfoSection').style.display = 'none';
		document.getElementById('dealDescription').className = 'dealNavButton';
		document.getElementById('dealFinePrint').className = 'dealNavButton';
		document.getElementById('dealMapsInfo').className = 'dealNavButton';
		document.getElementById(section+'Section').style.display = 'block';
		document.getElementById(section).className = 'dealNavButton on';
	}
}

function purchaseDealSelectCC(val){
	if (val == 'existing'){
		document.getElementById('newCCArea').style.display="none";
	}else{
		document.getElementById('newCCArea').style.display="";
	}
}

// Barcode Generator

BARS = [212222,222122,222221,121223,121322,131222,122213,122312,132212,221213,221312,231212,112232,122132,122231,113222,123122,123221,223211,221132,221231,213212,223112,312131,311222,321122,321221,312212,322112,322211,212123,212321,232121,111323,131123,131321,112313,132113,132311,211313,231113,231311,112133,112331,132131,113123,113321,133121,313121,211331,231131,213113,213311,213131,311123,311321,331121,312113,312311,332111,314111,221411,431111,111224,111422,121124,121421,141122,141221,112214,112412,122114,122411,142112,142211,241211,221114,413111,241112,134111,111242,121142,121241,114212,124112,124211,411212,421112,421211,212141,214121,412121,111143,111341,131141,114113,114311,411113,411311,113141,114131,311141,411131,211412,211214,211232,23311120];
START_BASE = 38
STOP = 106 //BARS[STOP]==23311120 (manually added a zero at the end)

var fromType128 = {
    A: function(charCode) {
        if (charCode>=0 && charCode<32)
            return charCode+64;
        if (charCode>=32 && charCode<96)
            return charCode-32;
        return charCode;
    },
    B: function(charCode) {
        if (charCode>=32 && charCode<128)
            return charCode-32;
        return charCode;
    },
    C: function(charCode) {
        return charCode;
    }
};

function code128(code, barcodeType) {
    if (arguments.length<2)
        barcodeType = code128Detect(code);
    if (barcodeType=='C' && code.length%2==1)
        code = '0'+code;
    var a = parseBarcode128(code,  barcodeType);
    return bar2html128(a.join('')) ;//+ '<label>' + code + '</label>';
}


function code128Detect(code) {
    if (/^[0-9]+$/.test(code)) return 'C';
    if (/[a-z]/.test(code)) return 'B';
    return 'A';
}

function parseBarcode128(barcode, barcodeType) {
    var bars = [];
    bars.add = function(nr) {
        var nrCode = BARS[nr];
        this.check = this.length==0 ? nr : this.check + nr*this.length;
        this.push( nrCode || format("UNDEFINED: %1->%2", nr, nrCode) );
    };

    bars.add(START_BASE + barcodeType.charCodeAt(0));
    for(var i=0; i<barcode.length; i++)
    {
        var code = barcodeType=='C' ? +barcode.substr(i++, 2) : barcode.charCodeAt(i);
        converted = fromType128[barcodeType](code);
        if (isNaN(converted) || converted<0 || converted>106)
            throw new Error(format("Unrecognized character (%1) at position %2 in code '%3'.", code, i, barcode));
        bars.add( converted );
    }
    bars.push(BARS[bars.check % 103], BARS[STOP]);

    return bars;
}

function format(c){
    var d=arguments;
    var e= new RegExp("%([1-"+(arguments.length-1)+"])","g");
    return(c+"").replace(e,function(a,b){return d[b]})
}

function bar2html128(s) {
    for(var pos=0, sb=[]; pos<s.length; pos+=2)
    {
        sb.push('<div class="bar' + s.charAt(pos) + ' space' + s.charAt(pos+1) + '"></div>');
    }
    return sb.join('');
}


// Google Maps

$('#DealMap').live("pagecreate", function() {
	if(navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(position){
			if (position == null){return showMapNoGeo();}
			document.getElementById('map_canvas').style.height = (parseInt($(window).height().toString())).toString()+'px';
			document.getElementById('map_canvas').style.width = $(window).width().toString()+'px';
			$('#map_canvas').gmap({ 'center': '' + position.coords.latitude + ',' + position.coords.longitude + ''}).gmap('option', 'zoom', 9);
			$('#map_canvas').gmap().bind('init', function() { 
				data = jQuery.parseJSON(localStorage.getItem('mapData'));
				$.each( data.markers, function(i, marker) {
							$('#map_canvas').gmap('addMarker', { 
								'position': new google.maps.LatLng(marker.latitude, marker.longitude), 
								'bounds': false 
							}).click(function() {
								$('#map_canvas').gmap('openInfoWindow', { 'content': marker.content }, this);
							});
						});
			});
		});
	}else{
		showMapNoGeo();
	}
});

function showMapNoGeo(){
	document.getElementById('map_canvas').style.height = $(window).height().toString()+'px';
	document.getElementById('map_canvas').style.width = $(window).width().toString()+'px';
	$('#map_canvas').gmap({ 'center': '27.950575,-82.457178'}).gmap('option', 'zoom', 9);
	$('#map_canvas').gmap().bind('init', function() { 
		data = jQuery.parseJSON(localStorage.getItem('mapData'));
		$.each( data.markers, function(i, marker) {
			$('#map_canvas').gmap('addMarker', { 
				'position': new google.maps.LatLng(marker.latitude, marker.longitude), 
				'bounds': false 
			}).click(function() {
				$('#map_canvas').gmap('openInfoWindow', { 'content': marker.content }, this);
			});
		});
	});
}


// Logout

function logout(){
	localStorage.clear();
	location.reload();
}

