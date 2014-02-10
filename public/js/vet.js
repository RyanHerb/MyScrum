// Run when any appointment page is loaded 
function setup_appointments($p) {

  // Workaround for pages not being removed from dom.
  $('.ui-page').bind('pagehide', function(event, ui){
    var page = $(event.target);
    if(page.attr('data-cache') == 'never'){
      page.remove();
    };
  });

  // timeline update flag. True by default so timeline remains unloaded until tab clicked.
  tl_updated = true;

  var active_tab = $('.nav_button.ui-btn-active', $p).attr('id');

  $("#" + active_tab + "_content", $p).show();

  $('.nav_button', $p).bind('click', function(){
    $('.ui-page-active .nav_content').hide();  // hide old content
    $('#' + $(this).attr('id') + '_content').show(); // show new content
  });

  $('#timeline').live('click', function(e){
    if(tl_updated){ timeline_load(); }
  });

  $('.add_note').live('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var form = $(this).closest('form');
    form.children('.error').remove();

    var url = form.attr('action');
    var pt = form.children('.pt').val();
    var pub = form.find('.note_public').prop('checked');

    if(/\S/.test(pt)){
      $.post(url, {'pt': pt, 'public': pub}, function(response){
        if(response == "OK"){
          $('#add_note_dialog textarea').val(''); // remove text from textarea, so clear for next note
          $('#add_note_dialog').popup('close');
          show_appointment_message('Note added to timeline');
          timeline_update();
        } else {
          form.append("<div class='error' style='color: red; text-align: center;'>Error adding note</div>");
        }
      });
    } else {
      form.append("<div class='error' style='color: red; text-align: center;'>Please enter a note</div>");
    }
    return false;
  });

  $('.start_appointment').bind('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var btn = $(this);
    var href = $(this).attr('href');
    $.post(href, function(response){
      if(response == "OK") {
        show_appointment_message("Appointment started");

        btn.removeClass('ui-btn-hover-c'); // need to remove this as applying disabled class will lock the button's color to orange (hover colour)
        btn.addClass('ui-disabled');

        $('.procedure-collapsible').find('.procedure-step-collapsible:first').find('.start_procedure_step, .skip_button').removeClass('ui-disabled'); // enable start/skip buttons for first step of each procedure.

      } else {
        display_appointment_error(response);
      }
    });
    return false;
  });

  $('.start_procedure_step').bind('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var btn = $(this);
    var href = btn.attr('href');
    $.post(href, function(response){
      if(response == 'OK') {
        btn.removeClass('ui-btn-hover-c');
        btn.addClass('ui-disabled'); // disable start
        btn.siblings('.skip_button').addClass('ui-disabled'); // disable skip
        btn.siblings('.finish_procedure_step').removeClass('ui-disabled'); // enable finish

        btn.parents('.procedure-collapsible').find('.delete_pet_procedure').remove();

        show_appointment_message('Step started');
      } else {
        display_appointment_error(response);
      }
    });
    return false;
  });

  $('.finish_procedure_step').bind('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var href = $(this).attr('href');
    var step = $(this).parents('.procedure-step-collapsible');
    var btn = $(this);
    var form = btn.parents('.ui-collapsible-content').children('form');
    var checkboxes = form.find(".checkbox_value:checked");

    if(checkboxes.length > 0){
      $("#product_list > .ui-block-a:not('.heading'), #product_list > .ui-block-b:not('.heading'), #product_list > .labelInstructions").remove(); // clear previous products

      $.each(checkboxes, function(){
        var ui_block_a = $('<div/>', {'class': 'ui-block-a', 'html': $(this).data('name'), 'data-product_id': $(this).attr('value')});

        var label_required_html = $('<select/>', {'class': 'label_required', 'data-role': 'slider', 'data-mini': 'true', 'data-product_id': $(this).attr('value')});
        label_required_html.append($('<option/>', {'value': 'false', 'html': 'No'}));
        label_required_html.append($('<option/>', {'value': 'true', 'html': 'Yes'}));

        var ui_block_b = $('<div/>', {'class': 'ui-block-b', 'html': label_required_html, 'data-product_id': $(this).attr('value')});
        
        var ui_block_c = $('<div/>', {'class': 'labelInstructions', 'id': 'labelInstructions_'+$(this).attr('value'), 'style': 'display: none;', 'data-product_id': $(this).attr('value')});
        ui_block_c.append("<textarea placeholder='Enter the instructions for this label'></textarea>");

        $('#product_list').append(ui_block_a);
        $('#product_list').append(ui_block_b);
        $('#product_list').append(ui_block_c);

        $('body').trigger('create'); // jq mobileize!
      });

      $('.label_required').change(function(){ // show the label textarea
        var sel = "#labelInstructions_" + $(this).data('product_id');
        if( $(this).val() == 'true' ){ $(sel).slideDown(250); } else { $(sel).hide(); }
      });

      $('#submit_dem_products').unbind('click');
      $('#submit_dem_products').click(function(e){
        e.preventDefault();
        var labels = $('#product_list select');
        finish_step(checkboxes, href, btn, step, labels);
        $('#finish_procedure_step_dialog').popup('close');

        // labels to make
        var product_ids = $('#product_list select').map(function(){ if($(this).val() == 'true'){ return $(this).data('product_id'); } }).get();
        var product_quantities = product_ids.map(function(id){ return $(".quantity_"+id).val(); });
        var instructions = product_ids.map(function(id){ return $("#labelInstructions_"+id+" textarea").val(); });
        var label_href = href.replace(/finish/, 'add_label');

        if(product_ids.length > 0){
          $.post(label_href, {'label_ids': product_ids, 'quantities': product_quantities, 'instructions': instructions}, function(res){
            show_appointment_message('Labels created');
          });
        }
        
        return false;
      });

      $('#finish_procedure_step_dialog').popup('open');
    } else {
      finish_step(checkboxes, href, btn, step);
    }

    return false;
  });

  $('.skip_button').bind('click', function(e){
    e.preventDefault();
    var url = $(this).attr('href');
    $.post(url, function(r){
      if(r == "OK"){
        show_appointment_message('Step skipped');
        var current_step = $(".procedure-step-collapsible:not('.ui-collapsible-collapsed')"); // TODO: Find better way of getting current step.
        move_to_next_step(current_step);
      }
    });
    return false;
  });

  $('.add_product_dialog').bind('click', function(e){
    try { $.mobile.sdCurrentDialog.destroy(); } catch(e) { }
    e.preventDefault(); e.stopImmediatePropagation();
    $("<div>").simpledialog2({
      mode: 'blank',
      headerText: 'Add product',
      headerClose: true,
      width: '560px',

      blankContent: 
      "<form class='productSearchContainer' style='margin: 10px;'>"+
        "<input type='text' class='productSearchField' placeholder='Search for a product' />"+
        "<input type='submit' class='productSearchSubmit' value='Search' />"+
        "<div style='display: none; text-align: center;' class='productSearchSpinner'><img src='/images/ajax-loader.gif' /></div>"+
        "<div class='productSearchResults' style='height: 250px;'></div>"+
      "</form>"
    });
    return false;
  });

  $('.productSearchField').keydown(function(e){
    e.preventDefault(); s.stopImmediatePropagation();
    return false;
  });

  $('.productSearchSubmit').live('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var parentDiv = $(this).parents('.productSearchContainer');
    parentDiv.children('.productSearchResults').html(''); // remove any previous results and hide
    parentDiv.find('.add_product_from_results').parent().remove(); // remove 'add selected product(s) button from previous search'

    var query = parentDiv.children('.productSearchField').val();
    if(/\S/.test(query)) {
      $.getJSON('/vet/appointment/product_search', {'q': query}, function(response){
        // TODO: the response only contains 5 results. Need to code way to show 5 at a time, as 5 is the maximum that'll fit in the dialog. overflow-y: scroll is not an option on ipad..
        var html;
        if(response.length > 0) {
          html = $('<p>', { 'class': 'hint', 'html': "Tick any products you want to add from the results below and then click 'Add selected product(s)" });
          $.each(response, function(index, value){

            var i = $('<input>', { type: 'checkbox', value: value[0], class: 'productSearchSelectedResult', data: { mini: true, name: value[1], units: value[2] } } );
            var l = $('<label>').append(i).append(value[1] + " ("+value[3]+")");
            $(html).append(l);

          });

          parentDiv.append("<button class='add_product_from_results' value='Add selected product(s)'/>").trigger('create');
        } else {
          html = "<p class='blankstate'>No products found matching '"+query+"'";
        }

        parentDiv.children('.productSearchResults').append(html).trigger('create');
      });
    } else {
      parentDiv.children('.productSearchField').attr('placeholder', 'You need to enter a search value!');
    }
    return false;
  });

  $('.add_product_from_results').live('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var checked_products = $(this).parents('.productSearchContainer').find("input[type='checkbox']:checked");
    if(checked_products.length > 0){
      var current_step = $(".procedure-collapsible:not('.ui-collapsible-collapsed') .procedure-step-collapsible:not('.ui-collapsible-collapsed')"); // need a better way of doing this
      var psp_products = current_step.find('.procedure_step_products');
      $.each(checked_products, function(index, value){
        
        var id = $(this).val();
        //var name = $(this).data('name');
        var name = $(this).parent().children('label').text();
        var dispensing_units = $(this).data('units');
        var quantity_value = 1; // could potentially get this from db too.

        html = $('<div/>', {'class': 'ui-block-a'}).append( $('<label/>', {'class': 'checkbox_label', 'html': name}).append( $('<input/>', {'class': "checkbox_value checkbox_"+id, 'type': 'checkbox', 'checked': 'checked', 'name': 'product[]', 'value': id, 'data-mini': true, 'data-name': name}) ) );
        raw_html = "<div class='ui-block-b'><span style='margin-left: 10px;'><span>x </span><input class='quantity_value quantity_"+id+"' type='text' name='quantity[]' value='"+quantity_value+"' data-theme='b' /><span class='dispensing_units'>&nbsp;"+dispensing_units+"</span></span></div>";
        raw_html += "<div class='ui-block-c'><label>Free<input type='checkbox' class='free_value' name='free[]' value='1' data-mini='true' data-inline='true' /></label></div>"
        raw_html += "<div class='ui-block-d'><a href='' class='delete_product' data-role='button' data-inline='true' data-icon='delete' data-iconpos='notext'></a></div>"
        
        html = html.after(raw_html);
        
        var html = $("<div class='procedure_step_product ui-grid-a' />").append(html);
        psp_products.append(html);
        
      });
      $('.procedure_step_product').trigger('create'); // initialize newly added html
      $.mobile.sdCurrentDialog.close();

    } else {
      alert('No products selected');
    }

    return false;
  });

  $('.delete_product').live('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    $(this).closest('.procedure_step_product').remove();
    return false;
  });

  $('.finish_appointment').live('click', function(){
    var a_id = $(this).parents('.ui-page.ui-page-active.appointment').data('appointment_id');
    $.ajax({
      type: "POST",
      url: "/vet/appointment/"+a_id+"/can_express",
      async: false,
      success: function(r){
        if(r == 'true' && $('#checkout_now').length == 0){ 
          $('#ready_for_checkout').before( $('<a/>', {'data-role': 'button', 'data-theme': 'c', 'href': '/vet/appointment/'+a_id+'/checkout_now', 'id': 'checkout_now', 'html': 'Express check out'}) );
          $('body').trigger('create');
        }
      }
    });
  });

  $('#checkout_now, #ready_for_checkout').live('click', function(e){
    e.preventDefault(); e.stopImmediatePropagation();
    var href = $(this).attr('href');
    var cnotes = $('#closeout_notes').val();
    var vfon = $('#vet_follow_on').prop('checked');
    $.post(href, {'close_out_notes': cnotes, 'vet_follow_on': vfon}, function(response){
      if(response == "OK"){
        $('.finish_appointment').addClass('ui-disabled');
        $('#add_another_procedure').hide();
        $('#finish_appointment_dialog').popup('close');
        show_appointment_message("Appointment finished");
        // redirecting doesn't seem to be working from dialog/popup. TODO fix!
        //$.mobile.changePage('/vet', {'reloadPage': true});
      } else {
        alert("Error: " + response);
      }
    });
    return false;
  });

  $('#add_media').live('click', function(e){
    var url = $(this).attr('rel');
    url += "?mediaTypeForCamera=photo";
    window.location.href = url;
  });

  $('.play_video_workaround').live('click', function(e){
    e.preventDefault();
    var player_id = $(this).siblings('.video-js').attr('id');
    var myPlayer = _V_( player_id );
    myPlayer.play();
    return false;
  });

  $('.delete_pet_procedure').bind('click', function(e){
    e.preventDefault();
    var href = $(this).attr('href');
    $('#delete_pet_procedure_dialog').popup('open');

    $('#confirm_rm_pet_procedure').live('click', function(e){
      e.preventDefault();
      $.post(href, {'_method': 'delete'}, function(response){
        if(response == "OK"){
          window.location.reload();
        } else {
          $('#delete_pet_procedure_dialog').popup('close');
          display_appointment_error(response);
        }
      });
      return false;
    });

    return false;
  });

  app_update_graph();

}

 
// Functions

function finish_step(checkboxes, href, btn, step, labels){
  var p = checkboxes.map(function(){ return $(this).val(); }).get(); // get values for the checkboxes (product IDs)
  var q = checkboxes.map(function(){ return $(this).parents('.procedure_step_product').find('.quantity_value').val(); }).get(); // get quantities for each product (out of those 'checked')
  var f = checkboxes.map(function(){ return $(this).parents('.procedure_step_product').find('.free_value').prop('checked'); }).get(); // get quantities for each product (out of those 'checked')
  
  $.post(href, {'products': p, 'quantities': q, 'free': f}, function(response){
    if(response == "OK") {
      btn.addClass('ui-disabled'); // disable the finished button
      show_appointment_message('Step finished');

      move_to_next_step(step);
    } else {
      display_appointment_error(response);
    }
  });
}

function move_to_next_step(current_step) { // current_step should be .procedure-step-collapsible as jq object
  current_step.trigger('collapse'); // close current step
  var next_step = current_step.next('.procedure-step-collapsible');
  
  if (next_step.length > 0) { // if there is a next step..
    next_step.trigger('expand'); // open it..
    next_step.find('.start_procedure_step, .skip_button').removeClass('ui-disabled'); // and enable start & skip buttons
  } else { // no more steps!
    show_appointment_message('Procedure finished');
    current_step.closest('.procedure-collapsible').addClass('procedure-finished');
    toggle_tick(current_step.closest('.procedure-collapsible')); // show tick to indicate procedure is finished
    
    if(appointment_is_finished($('.ui-page-active').data('appointment_id'))){ // ajax call to see if any procedures left for whole appointment or not.
      $('.start_appointment').addClass('hidden');
      $('.finish_appointment').removeClass('hidden');
      $('.finish_appointment').removeClass('ui-disabled');
    }
  }
}

function timeline_update(){
  tl_updated = true;
  
  if(!$('#timeline .notification_num').hasClass('new')) { $('#timeline .notification_num').addClass('new'); }

  var curr_num = $('#timeline .notification_num').text();
  if(curr_num == ""){ curr_num = 0; } else { curr_num = parseInt(curr_num) }

  $('#timeline .notification_num').text(curr_num + 1);
}

function timeline_load(){
  tl_updated = false;
  $('#timeline .notification_num').text('');
  $('#timeline .notification_num').removeClass('new');

  $('.plogs').after("<p id='ajaxloader' style='text-align: center;'><img src='/images/ajax-loader-g.gif' /></p>");
  
  var pl_ids = []; $('.plog').each(function(){ pl_ids.push($(this).data('id')); });
  var aid = $('.ui-page-active.appointment').data("appointment_id");
  var pid = $('.ui-page-active.appointment').data("pet_id");
  $.get("/vet/appointment/"+aid+"/"+pid+"/get_plogs", {'nin': pl_ids}, function(dem_plogz){
    if(dem_plogz.length > 0){
      $('#ajaxloader').before(dem_plogz);
      $("div[data-role='popup']").popup(); // initialize popup for any plog photos
      $("div[data-role='popup']").trigger('create'); // and initialize new jquery mobile elements (popup close button)
      $('#noplogs').remove();
    } else {
      $('#ajaxloader').before("<div id='noplogs' class='blankstate'>No timeline entries</div>");
    }
    $('#ajaxloader').remove();
  }).error(function(a,b,c){ alert("Error loading timeline: " + c); $('#ajaxloader').remove(); });
}

function mediaUploaded(){
  show_appointment_message("Media uploaded");
  timeline_update();
}

function toggle_tick(procedure){
  if(!procedure.hasClass('procedure-collapsible')){ throw new Error("Argument is not a .procedure-collapsible"); }
  procedure.find('.finished_tick_cross .tick').toggle();
  procedure.find('.finished_tick_cross .cross').toggle();
}

function appointment_is_finished(appointment_id){
  $.ajax({
    url: "/vet/appointment/"+appointment_id+"/is_finished",
    async: false,
    success: function(r){ result = r; }
  });
  if(result == "true"){ return true; } else if(result == "false"){ return false; }
}

function show_appointment_message(msg) {
  var msg_field = $('.appointment_msg');
  msg_field.text(msg).fadeTo(250, 1);
  setTimeout(function(){ msg_field.fadeTo(250, 0); }, 2500);
}

function display_appointment_error(error){ 
  $('<div>').simpledialog2({
    mode: 'blank',
    headerText: 'Error',
    headerClose: true,
    blankContent:
      "<div style='margin: 10px;'>"+error+"</div>"
  });
}

var app_trend_data = {};

function app_update_graph() {

  $.each( $('.appointment_graph'), function() {
    var gid = $(this).attr('id');
    var key = $(this).data('key');
    var label = $(this).data('label');

    if( $("#" + gid).length > 0 && $("#" + gid + " svg").length == 0 ) {
      Morris.Line({
        element: gid,
        data: app_trend_data[key],
        xkey: 'y',
        ykeys: ['a'],
        labels: [label],
        hideHover: true
      });
    }

  });
}