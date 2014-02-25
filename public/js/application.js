/*-------------------------------------------------------------
 * Collection of useful jquery things common to several sites!
 *
 * Add your own!!
 *-------------------------------------------------------------*/

var apiDataTables = {};

function setupDataTables() {

 $.each($('table.datatable'), function() {

   var tbl = $(this);
   var tblid = $(this).attr('id');

   var display = 25;
   if ($(this).hasClass('display-10')) {display = 10};
   
   var saveState = false;
   if ($(this).hasClass('savestate')) { saveState = true };

   var hasAPI = tbl.parent().hasClass('dataTables_wrapper');

   if (!hasAPI) {
     //TODO: may want to add "bStateSave": true so that state is saved for ajax requests. Might not work with custom filter's though

     var api = tbl.dataTable({"bStateSave" : saveState, "iDisplayLength": display, "bAutoWidth": false, "sDom": '<"top"if>rt<"bottom"lp><"clear">'});
     if (tblid) apiDataTables[tblid] = api;

     var i = 0, ar = [];

     $('thead th', tbl).each(function() {
       if ($(this).hasClass('sort')) ar.push([i,'asc']);
       if ($(this).hasClass('sortdesc')) ar.push([i,'desc']);
       if ($(this).hasClass('nosort')) $(this).unbind('click');
       i++;
     });
     if (ar.length > 0) api.fnSort(ar);
   } 

 });
 
 $('tr.selectable').live('click', function() {
   var link = $(this).closest('tr').attr('rel');
   window.location = location.protocol + '//' + location.host + link;
 });
 
 $('tr.selectable td a').live('click', function(e) {
   e.stopPropagation();
 });
 
}

function scrollPageTo(element) {
  if ( $(element).length > 0 ) {    
    $('html,body').animate({ scrollTop: $(element).offset().top }, { duration: 'slow', easing: 'swing'});
  }
}

function show_flash_notification() {
  $(function(){
    $('#flash').slideDown();
    setTimeout(function(){ $('#flash').slideUp(); }, 2500);
    $('#flash').mouseover(function(){ 
      $(this).slideUp(); 
    });
  });
}

function setup_custom_confirm(prompt, caller_id) {
  var id = "custom-dialog-" + ($('ui-dialog').length + 1);
  $('body').append("<div class='ui-dialog' id='"+id+"' style='display: none;'>"+prompt+"</div>");
  $('#'+id).dialog({
    modal: true,
    buttons: [ 
      {
        text: "Cancel",
        click: function() { $(this).dialog("close"); }
      },
      {
        text: "Confirm",
        click: function() { $(this).dialog("close"); $(caller_id).submit() }
      }
    ]
  });
}

function setup_delete_links() {
  // This makes a link with the delete_link class send a with DELETE verb
  $('.delete_link').live('click', function(e){
    e.preventDefault();
    var path = $(this).attr('href');
    var prompt = $(this).attr('rel');
    var redirect = $(this).attr('rev');

    // if (confirm(prompt)) {
    var dialog_id = "custom-dialog-" + ($('.ui-dialog').length + 1);
    $('body').append("<div class='ui-dialog' id='"+dialog_id+"' style='display: none;'>"+prompt+"</div>");
    $('#'+dialog_id).dialog({
      modal: true,
      draggable: false,
      buttons: [ 
        { text: "Cancel", click: function() { $(this).dialog("close"); } },
        { text: "Confirm", click: function() {
            $.post(path, {'_method' : 'delete'}, function(ret){
              if (ret == "OK") {
                if (redirect) {
                  if (redirect.match(/^#eval__/)) {  
                    var run = redirect.replace(/^#eval__/,'');
                    eval(run);
                    $('#'+dialog_id).dialog("close");
                  } else {
                    window.location = redirect;
                  } 
                } else {
                  window.location.reload();
                }            
              } else {
                error_message = ret.replace('ERROR', '').trim();
                alert("Sorry, but I can't delete this object. " + error_message);
              }
            });
          }
        }
      ]
    });
    //}
    //return false;
  });
}

function setup_form_dialogs() {
  // This makes the forms open in a dialog box
  $('.dialogformlink').live('click', function(e){
    e.preventDefault();
    var formDiv = $(this).attr('href');
    
    if ($(this).data('flds')){ 
      var formFields = $(this).data('flds');
    }
    
    if ($(this).data('vals')){ 
      var formVals = $(this).data('vals');
    }
    
    if ($(this).data('model')){ 
      var formModel = $(this).data('model');
    }
    
    if ($(this).data('wide')){
      var dialogWidth = $(this).data('wide');
    } else {
      var dialogWidth = 300;
    }

    if ($(this).data('high')){
      var dialogHeight = $(this).data('high');
    } else {
      var dialogHeight = 400;
    }
    
    if (formFields){
      var fields = formFields.split(',');
      var vals = formVals.toString().split(',');
      $(fields).each(function(i){
        fields[i] = $.trim(fields[i]);
        $('form', '#' + formDiv).prepend('<input type="hidden" name="' + formModel + '[' + fields[i] + ']" value="' + vals[i] + '" />');
        i++;
      });
    }

    $('form', '#' + formDiv).attr('action', $(this).attr('rel'));

    $('#' + formDiv).dialog({
      resizable: false,
      width: dialogWidth,
      height: dialogHeight,
      modal: true
    });
  });
}

function setup_datepicker() {
  $('input.date').datepicker({
    changeYear: true,
    dateFormat:"dd/mm/yy",
    change: function() {
      var isoDate = this.getValue('yyyy-mm-dd');
      $(this).attr('data-value', isoDate);
    }
  });

  $(".datePicker").datepicker({
    showOn: 'button',
    
});
}

function setup_timepicker() {
  if( $('input.time').length > 0 ){
    $('input.time').timepicker();
  }
}

function setup_tabs() {
  $(".tabs").tabs();
}

function dialog_alert(msg){
  var dia = $('<div/>', {'class': 'dialog_alert', html: msg});
  dia.appendTo( $('body') );
  dia.dialog({
    draggable: false,
    modal: true,
    buttons: { "OK": function() {
      $(this).dialog('destroy').remove()
      //$(this).parent().remove();
    }}
  });
}

Array.prototype.removeValue = function(val) {
  return this.filter(function(v) {
    return v != val;
  });
}

Array.prototype.removePartById = function(id) {
  return this.filter(function(v) {
    return v.id != id;
  });
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function ajax_put(url){
  $.post(url, {'_method': 'PUT'}, function(r){
    window.location.reload();
  }).error(function(e){ dialog_alert(e.status + ": " + e.statusText); });
}


function change_postit_state(postit, state) {
  var container = $("#container_" + postit.data('id') + "_" + state);
  container.append(postit);
  $.post(postit.data('action') + '/' + state, function(res) {
    if(res == 'OK') {
    }
  });
}

$(document).ready(function(){
  show_flash_notification();
  setupDataTables();
  setup_delete_links();
  setup_form_dialogs();
  setup_datepicker();
  //timepicker breaks certain pages
  //setup_timepicker();
  setup_tabs();
});