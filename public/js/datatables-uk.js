jQuery.fn.dataTableExt.oSort['num-html-asc']  = function(a,b) {
  var x = a.replace( /<.*?>/g, "" );
  var y = b.replace( /<.*?>/g, "" );
  x = parseFloat( x );
  y = parseFloat( y );
  return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['num-html-desc'] = function(a,b) {
  var x = a.replace( /<.*?>/g, "" );
  var y = b.replace( /<.*?>/g, "" );
  x = parseFloat( x );
  y = parseFloat( y );
  return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['uk_date-asc']  = function(a,b) {
  var ukDatea = a.split(/\D/);
  var ukDateb = b.split(/\D/);
  
  var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
  var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;
  
  return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['uk_date-desc'] = function(a,b) {
  var ukDatea = a.split(/\D/);
  var ukDateb = b.split(/\D/);
  
  var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
  var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;
  
  return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
};

jQuery.fn.dataTableExt.aTypes.unshift(function(g) {
  if (typeof g == "string") {
    if (g.match(/^[0123]?\d\D[01]?\d\D(19|20|21)?\d\d/)) {
      return 'uk_date';
    }
  }
  return null;
});