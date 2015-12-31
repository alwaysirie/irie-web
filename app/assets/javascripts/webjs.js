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
		if (section == 'dealMapsInfo'){
			initialize();
		}
	}
}

function purchaseDealSelectCC(val){
	if (val == 'existing'){
		document.getElementById('newCCArea').style.display="none";
		document.getElementById('billingAddressArea').style.display="none";
		document.getElementById('existingCCWrapper').id="existingCCWrapperSelected";
		document.getElementById('radioNewCC').style.display="";
	}else{
		document.getElementById('newCCArea').style.display="";
		document.getElementById('billingAddressArea').style.display="";
		document.getElementById('existingCCWrapperSelected').id="existingCCWrapper";
		document.getElementById('radioNewCC').style.display="none";
	}
}