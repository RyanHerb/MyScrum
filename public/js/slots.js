$(function(){
  setCanvasWidth();
  $(window).resize(function() {
    setCanvasWidth();
  })
  
  // resizable every slots
  $('.slot').resizable({ handles: 'e, w', containment: 'parent', stop: stopResizeSlot });

  // draggable every slots
  $('.slot').draggable({ containment: 'parent', stop: stopDragSlot });

  
  
  // display dialog to edit object (working_pattern_session or user_session)
  $('.slot').live('dblclick', function(e) {
    e.stopPropagation();
    $('#errors').hide();
    var slot = $(this);
    var row = slot.parent();
    var object_class = row.data('class');
    var dialog = $('#'+ object_class +'_dialog');
    
    // console.log(slot.data('start_h'));
    // console.log(slot.data('start_m'));
    // console.log(slot.data('end_h'));
    // console.log(slot.data('end_m'));
    // console.log(slot.data('type'));
    // set data inside form
    if( object_class == 'working_pattern_session') {
      $('#working_pattern_session_start_time_h').val( slot.data('start_h') );
      $('#working_pattern_session_start_time_m').val( slot.data('start_m') );
      $('#working_pattern_session_end_time_h').val( slot.data('end_h') );
      $('#working_pattern_session_end_time_m').val( slot.data('end_m') );
      
      $('#working_pattern_session_id').val( slot.data('id'));
      $('#working_pattern_session_working_pattern_id').val( row.data('working_pattern_id') );
      $('#working_pattern_session_day').val( row.data('day') );
    } else {
      $('#user_session_start_time_h').val( slot.data('start_h') );
      $('#user_session_start_time_m').val( slot.data('start_m') );
      $('#user_session_end_time_h').val( slot.data('end_h') );
      $('#user_session_end_time_m').val( slot.data('end_m') );
      
      $('#user_session_id').val( slot.data('id'));     
      $('#user_session_day').val( row.data('day') );
      $('#user_session_user_id').val( row.data('user_id') );
      $('#user_session_session_type').val( slot.data('type'));
    }
    

    dialog.dialog();
  });

  // display dialog to add new object (working_pattern_session or user_session)
  $('.slots').live('dblclick', function(e) {
    $('#errors').hide();
    var row = $(this);
    var object_class = row.data('class');
    var dialog = $('#'+ object_class +'_dialog');1

    // calculate clicked hour
    var x = e.offsetX, totalWidth = $(this).width();
    // console.log("slots total width = " + totalWidth);
    // console.log("clicked point = "+ x);
    // var tq = Math.round((x/totalWidth) * 25 * 4); // time in 15 minutes
    var tq = Math.round( (x/ (totalWidth - 0.04 * totalWidth)) * 16 * 6); // time in 10 minutes
    // console.log("x / total width - 8% = "+ Math.round( (x/ (totalWidth - 0.08 * totalWidth))) );
    // var h = parseInt(tq/4);
	  var h = parseInt(tq/6) + 7;
    // console.log("time quarter - "+ tq);
    // console.log("godizna startu - "+ h);
    // we have 17 hours on the grid!
    if (h >= 22) return;

    // calculate start minute
    // var m = (tq - (h * 4)) * 15;
	  var m = (tq - ((h - 7) * 6)) * 10;
    // console.log("minuta startu - "+ m);

    // calculate end hour, and end minute
    var eh = 0;
    var em = 0;
	
	// TODO change to 16 hours
    switch(h) {
    case 22:
    case 21:
    case 20:
    case 19:
      eh = 22
      em = 0
      break;
    default:
      eh = h + 3
      em = m
    }

    // set data inside form
    if( object_class == 'working_pattern_session') {
      $('#working_pattern_session_start_time_h').val(h);
      $('#working_pattern_session_start_time_m').val(m);
      $('#working_pattern_session_end_time_h').val(eh);
      $('#working_pattern_session_end_time_m').val(em);

      $('#working_pattern_session_working_pattern_id').val( row.data('working_pattern_id') );
      $('#working_pattern_session_day').val( row.data('day') );
    } else {
      $('#user_session_start_time_h').val(h);
      $('#user_session_start_time_m').val(m);
      $('#user_session_end_time_h').val(eh);
      $('#user_session_end_time_m').val(em);
      
      $('#user_session_user_id').val( row.data('user_id') );
      $('#user_session_day').val( row.data('day') );
      
    }


    dialog.dialog();
  });


  // click on submit button within dialog
  $('#dialog_submit').live('click', function(e) {
    e.preventDefault();
    var object_class = $(this).data('class');
    var dialog = $('#'+ object_class +'_dialog');


    // if slot is new
    if( !$('#'+ object_class + '_id').val() ) {

      url = '';
      if( object_class == 'working_pattern_session' ) { // working_pattern_sessions
        url = '/admin/working_pattern_sessions'
        
        var start_h = $('#working_pattern_session_start_time_h').val();
        var start_m = $('#working_pattern_session_start_time_m').val();
        var end_h = $('#working_pattern_session_end_time_h').val();
        var end_m = $('#working_pattern_session_end_time_m').val();
        var session_type = $('#working_pattern_session_session_type').val();

        var day = $('#working_pattern_session_day').val();
        // var width = (end_h * 4 + end_m /15 ) - (start_h * 4 + start_m / 15);
		    var width = (end_h * 6 + end_m /10 ) - (start_h * 6 + start_m / 10);

        var row = $('.slots[data-day='+ day +']');
          
        $('#working_pattern_session_start_time').val( start_h +':'+ start_m );
        $('#working_pattern_session_end_time').val( end_h +':'+ end_m );
      } else { // user_sessions
        url = '/admin/user_sessions'
        
        var start_h = $('#user_session_start_time_h').val();
        var start_m = $('#user_session_start_time_m').val();
        var end_h = $('#user_session_end_time_h').val();
        var end_m = $('#user_session_end_time_m').val();
        var session_type = $('#user_session_session_type').val();

        var day = $('#user_session_day').val();
        var user_id = $('#user_session_user_id').val();
        
        //  var width = (end_h * 4 + end_m /15 ) - (start_h * 4 + start_m / 15);
		    var width = (end_h * 6 + end_m /10 ) - (start_h * 6 + start_m / 10);
		
        var row = $('.slots[data-day='+ day +'][data-user_id='+ user_id +']');
          
        $('#user_session_start_at').val( day +' '+ start_h +':'+ start_m );
        $('#user_session_end_at').val( day +' '+ end_h +':'+ end_m );
      }


      $.post(url, $('form').serialize(), function(obj){
        obj = $.parseJSON(obj);
        if( obj.id ) {
          var slot_id = obj.id;
          
         
          
          // create slot
          var div = jQuery('<div/>', {
                class: 'slot '+ session_type,
                // style: 'left:'+ Math.round(start_h * 4 + start_m / 15) +'%; width: '+ width +'%; position: absolute;',
				         style: 'left:'+ Math.round((start_h - 7) * 6 + start_m / 10) +'%; width: '+ width +'%; position: absolute;',
                'data-id': slot_id,
                'data-start_h': start_h,
                'data-start_m': start_m,

                'data-end_h': end_h,
                'data-end_m': end_m,
                'data-type': session_type
          });

          delete_link = $('<a/>', {href: url +'/'+ slot_id , rel: 'Are you sure ?', class: 'floatright delete_link hidden', style: 'margin: -2px 2px 0 0'})
          $('<img/>', {src: '/img/icons/delete-8px.png', title: 'delete'}).appendTo(delete_link);
          delete_link.appendTo(div);

          save_link = $('<a/>', {rel: url +'/'+ slot_id, class: 'saveSlot floatright hidden', href: '#'}).appendTo(div);
          $('<img/>', {src: '/img/icons/tick-8px.png', title: 'save'}).appendTo(save_link);
          var times = jQuery('<div/>', { class: 'times', text: start_h +':'+ start_m +' '+ end_h +':' + end_m}).appendTo(div);
          // var slot_type = jQuery('<div/>', {class: 'slot_type', text: 'CONSULTING'}).appendTo(div);


          div.resizable({ handles: 'e, w', containment: 'parent', stop: stopResizeSlot});
          div.draggable({ containment: 'parent', stop: stopDragSlot });
          div.appendTo(row);
          updateTimes(div);
          dialog.dialog('close');
          
          
          
          
        } else {
          // we have validation errors
          // console.log(obj);
          $('#errors').html(obj.errors.join('<br />')).show();
        }

      });

    } else { // update existing slot
     
       url = '';
        if( object_class == 'working_pattern_session' ) { // working_pattern_sessions
          url = '/admin/working_pattern_sessions/'+ $('#working_pattern_session_id').val();

          var start_h = $('#working_pattern_session_start_time_h').val();
          var start_m = $('#working_pattern_session_start_time_m').val();
          var end_h = $('#working_pattern_session_end_time_h').val();
          var end_m = $('#working_pattern_session_end_time_m').val();
          var session_type = $('#working_pattern_session_session_type').val();

          var day = $('#working_pattern_session_day').val();
          // var width = (end_h * 4 + end_m /15 ) - (start_h * 4 + start_m / 15);
		      var width = ((end_h - 7)* 6 + end_m /10 ) - ((start_h -7) * 6 + start_m / 10);

          var row = $('.slots[data-day='+ day +']');

          $('#working_pattern_session_start_time').val( start_h +':'+ start_m );
          $('#working_pattern_session_end_time').val( end_h +':'+ end_m );
        } else { // user_sessions
          url = '/admin/user_sessions/' + $('#user_session_id').val();

          var start_h = $('#user_session_start_time_h').val();
          var start_m = $('#user_session_start_time_m').val();
          var end_h = $('#user_session_end_time_h').val();
          var end_m = $('#user_session_end_time_m').val();
          var session_type = $('#user_session_session_type').val();

          var day = $('#user_session_day').val();
          var user_id = $('#user_session_user_id').val();

          // var width = (end_h * 4 + end_m /15 ) - (start_h * 4 + start_m / 15);
		      var width = ((end_h -7) * 6 + end_m /10 ) - ((start_h - 7) * 6 + start_m / 10);
		
          var row = $('.slots[data-day='+ day +'][data-user_id='+ user_id +']');

          $('#user_session_start_at').val( day +' '+ start_h +':'+ start_m );
          $('#user_session_end_at').val( day +' '+ end_h +':'+ end_m );
        }
        
        
        var data = $('form').serializeArray();
        data.push( { name: '_method', value: 'put'} );
        // console.log(url);
        $.post(url, data, function(obj){
          obj = $.parseJSON(obj);
          // console.log(obj);
          if( !obj.errors) {
            var slot = $('.slot[data-id='+ obj.id +']');
            slot.css('left', obj.left+'%');
            slot.css('width', obj.width+'%');
            
            slot.data('start_h', obj.start_h);
            slot.data('start_m', obj.start_m);
            slot.data('end_h', obj.end_h);
            slot.data('end_m', obj.end_m);
            
            slot.removeClass("operating");
            slot.removeClass("consulting");
            slot.removeClass("blocked");
            slot.addClass(obj.session_type);
            dialog.dialog('close');
          } else {
            // console.log(obj.errors.join('<br />'));
            $('#errors').html(obj.errors.join('<br />')).show();
          }
          
        });
        
        //slot.css('left', ui.originalPosition.left);
        //slot.css('width', ui.originalSize.width);
      
    }
    // dialog.dialog('close');
    
    
   

  });



  // save slot
  $('.saveSlot').live('click', function(e){
    e.preventDefault()
    var slot = $(this).parent();
    var link = $(this);

    var start_at = '';
    var end_at = '';

    var object_class = slot.parent().data('class');
    if( object_class == 'working_pattern_session' ) {

    } else {
      day = slot.parent().data('day');
      start_at = day +' ';
      end_at = day +' ';
    }


    start_at = start_at + slot.data('start_h') +':'+ slot.data('start_m');
    end_at = end_at + slot.data('end_h') +':'+ slot.data('end_m');

    opts = {};
    // if( object_class == 'user_session') { }

    if( object_class == 'working_pattern_session') {
      opts = {
        '_method' : slot.data('id') ? 'put' : 'post',
        'working_pattern_session[day]': slot.parent().data('day'),
        'working_pattern_session[working_pattern_id]': slot.parent().data('working_pattern_id'),
        'working_pattern_session[padding_factor]': 1,
        'working_pattern_session[start_time]': start_at,
        'working_pattern_session[end_time]': end_at
      };
    } else {
      opts = {
        '_method' : slot.data('id') ? 'put' : 'post',
        'user_session[user_id]': slot.data('user_id'),
        'user_session[start_at]': start_at,
        'user_session[end_at]': end_at
      };
    }

    $.post(link.attr('rel'), opts, function(res){
      // console.log(res);
      link.parent().removeClass('dirty');
      // console.log(res);

      // if slot exist in db, we gonna change the link
      if(!slot.data('id')) {
        slot.data('id', res);
        link.attr('rel', link.attr('rel') +'/'+slot.data('id'));
        slot.find('.delete_link').attr('href', slot.find('.delete_link').attr('href')+"/"+slot.data('id'));
      }
      slot.find('.delete_link').show();
      link.hide();
    });
  });

  // show links on hover (delete and save)
  $('.slot').live('hover', function(e) {

    var slot = $(this);
    // check if in other browser is the same
    // console.log(e.type);

    // mouseenter
    if(e.type == 'mouseenter') {
      // check if it's existing user session
      if( slot.data('id') ) {
        slot.find('.delete_link').show();

      }

      if( slot.hasClass('dirty') ) {
        slot.find('.saveSlot').show();
      }

      return true;
    }

    // mouse leave
    if(e.type == 'mouseleave') {
      slot.find('.delete_link').hide();
      slot.find('.saveSlot').hide();
      return true;
    }
  });


});
// end jquery document ready


// stop drag event hook
function stopDragSlot(e, ui) {
  var slot = $(this);

  //
  slot.addClass('current');

  // get variables from size
  var left = ui.position.left;
  var right = ui.position.left + slot.width();


  if( isOverlapConflict(left, right, slot) ) {
    slot.css('left', ui.originalPosition.left);
    slot.removeClass('current');
    setSlotPercentageValue(slot);
    updateTimes(slot);
    return;
  }

  if( isOutOfTime(right, slot.parent()) ) {
    slot.css('left', ui.originalPosition.left);
    slot.removeClass('current');
    setSlotPercentageValue(slot);
    updateTimes(slot);
    return;
  }

  // set slot data attr for hour and minutes
  setSlotData(slot);

 
  slot.addClass('dirty');
 
  slot.removeClass('current');
  slot.find('.saveSlot').show();
  setSlotPercentageValue(slot);
  updateTimes(slot);
  // slot.css('width', calculateLeft(slot) + 'px');
  
}

// stop resize event hook
function stopResizeSlot(e, ui) {
  var slot = $(this);
  // slot = $('.slot[data-id='+ $(this).data('id') +']');
  // console.log(slot);
  // get variables from size
  var left = ui.position.left;
  var right = ui.position.left + ui.size.width;



  // check if no overlaps and time is correct
  if( isOverlapConflict(left, right, slot) ) {
    slot.css('left', ui.originalPosition.left);
    slot.css('width', ui.originalSize.width);
    setSlotPercentageValue(slot);
    updateTimes(slot);
    slot.removeClass('current');
    return false;
  }

  // check if slot is in 25
  if( isOutOfTime(right, slot.parent()) ) {
    slot.css('left', ui.originalPosition.left);  
    setSlotPercentageValue(slot);
    updateTimes(slot);  
    return;
  }

  // set slot data attr for hour and minutes
  setSlotData(slot);


  // class means not save
  slot.addClass('dirty');

  slot.find('.saveSlot').show();
  
  setSlotPercentageValue(slot);
  updateTimes(slot);
}


// set html5 data for slot
function setSlotData(slot) {
  var left = slot.position().left;
  var right = slot.position().left + slot.width();

  var totalWidth = slot.parent().width();
	
  // var stq = Math.round( (left / totalWidth) * 25 * 4 ); // time in 15 minutes
  var stq = Math.round( (left / (totalWidth - 0.04 * totalWidth)) * 16 * 6 ); // time in 10 minutes
  // console.log(stq);
  var sh = parseInt(stq / 6) + 7; // add 7 hours we start from 7pm
  // console.log(sh);
  var sm = (stq - ((sh - 7) * 6)) * 10;
  // console.log(sm);

  // var etq = Math.round( (right / totalWidth) * 25 * 4 ); // time in 15 minutes
   var etq = Math.round( (right / (totalWidth - 0.04 * totalWidth)) * 16 * 6 ); // time in 10 minutes
  var eh = parseInt(etq / 6) + 7; // add 7 hours we start from 7pm
  var em = (etq - ((eh - 7) * 6)) * 10;

  // set new vars
  slot.data('start_h', sh);
  slot.data('start_m', sm);

  slot.data('end_h', eh);
  slot.data('end_m', em);
}

// TODO add coments
function isOverlapConflict(left, right, slot) {

  var overlap = false;
  slot.siblings().each(function(index) {
    other_slot = $(this);

    l = other_slot.position().left;
    r = l + other_slot.width();

    if( l < right && r > left  ) {

      overlap = true;
      return;
    }

  });

  return overlap;
}

// ===========================================
// = when someone move slot outside the grid =
// ===========================================
function isOutOfTime(right, row) {
  var row_width = row.width();
  // console.log(row);
  // console.log("row width = "+ row_width);
  // console.log("right - "+ right);
  var hour_in_pixels = Math.round((row_width - 0.04 * row_width) / 15);
  if(right - 5 > (row_width - 0.04 * row_width) - hour_in_pixels) {
    return true
  }
  return false
}

// ========================================================
// = set percent value of left and width (resize browser) =
// ========================================================
function setSlotPercentageValue(slot) {
  var left = (slot.data('start_h') - 7) * 6 + slot.data('start_m') / 10;
  var width = ( ((slot.data('end_h') - 7) * 3600 + slot.data('end_m') * 60 ) - ( (slot.data('start_h') - 7) * 3600 +  slot.data('start_m') * 60) ) / 600
  slot.css('left', left +'%');
  slot.css('width', width + '%');
}

// =============================================
// = update div.times with corect time string  =
// =============================================
function updateTimes(slot) {
  var sh = slot.data('start_h');
  var sm = slot.data('start_m');
  
  var eh = slot.data('end_h');
  var em = slot.data('end_m');
  
  if( sh < 10) {
    sh = '0' + sh.toString();
  }
  
  if( sm == 0 ) {
    sm = sm.toString()+ '0';
  }
  
  if( eh < 10) {
    eh = '0' + sh.toString();
  }
  
  if( em == 0) {
    em = em.toString()+ '0';
  }
  start_at = sh +':'+ sm;
  end_at = eh +':'+ em;
  slot.find('.times').html(start_at +'-'+ end_at);
}

function setCanvasWidth() {
  var calendar_width = $('.calView:visible').eq(0).width();
  canvas_width = Math.floor((calendar_width + 0)/120) * 120;
  // console.log("canvas width -" + canvas_width);
  if(canvas_width > 960) {
    $('.working_pattern_canvas').css('width', canvas_width + 'px');
  } else {
    $('.working_pattern_canvas').css('width', 960 + 'px');
  }
}
