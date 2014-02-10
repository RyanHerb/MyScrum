// Rotating elements - use like this: setInterval("rotateBanner('.rotating img', 1000)", 5000);
// You can specify a navigator element in the rotating element's ref attribute. This will be .selected
function rotateBanner(container, elementsDom, options) {

  if (!options) options = {};
  if (!options['dir']) options['dir'] = 'next';
  if (!options['speed']) options['speed'] = 1000;
    
  var elements = $(elementsDom, container); // $('#slider .slide')
  var current  = ( elements.filter('.current').length == 1 ? elements.filter('.current') : elements.eq(0) );
  var next;
  
  var indicator = $($(container).attr('rel'));
  
  if (options['goto']) {
    next = elements.eq(options['goto']-1);
  } else if (options['dir'] == 'next') {
    next = current.next();
    if (!next || next.length == 0) next = elements.eq(0);
  } else {
    next = current.prev();
    if (!next || next.length == 0) next = elements.eq(elements.length - 1);
  }

  $(elements).removeClass('current');
  $(next).addClass('current');
  $(current).fadeOut(options['speed']);
  $(next).fadeIn(options['speed']);
  
  if (indicator.length > 0) {
    var kids = $(container).attr('rev') ? $(container).attr('rev') : 'div';
    $(kids, indicator).removeClass('current');
    var k = $(next).attr('rel');
    $(k).addClass('current');
  }
  
  
}