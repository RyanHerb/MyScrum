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

function storeData(action, method, data) {
  var hash = new Object();
  hash['action'] = action;
  hash['method'] = method;
  hash['data'] =  data;
  localStorage.setItem(localStorage.length, JSON.stringify(hash));
}

function change_postit_state(postit, state) {
  var container = $("#container_" + postit.data('id') + "_" + state);
  container.append(postit);
  $.post(postit.data('action') + '/' + state, function(res) {
  }).fail(function (res) {
    // no need for data, the simple posting suffices to change the state
    storeData(postit.data('action') + '/' + state, "post", "");
  });
}

function storeFormData(form) {
  var serializedFormArray = form.serializeArray();
  var method;
  if(serializedFormArray[0]['name'] == "_method") {
    method = serializedFormArray[0]['value'];
    serializedFormArray.shift();
  } else {
    method = 'post';
  }
  storeData(form.attr('action'), method, form.serialize());
}

function uploadLocalStorage() {
  var storageElement;
  $.each(localStorage, function(index, value) {
    storageElement = JSON.parse(value);
    $.post(storageElement['action'], storageElement['data'], function(res) {
    }).done(function (res) {
      localStorage.removeItem(index);
    }).fail(function (res) {
      var r = confirm("An error occured while uploading some of your local changes, try again later?")
      if(r != true) {
        localStorage.removeItem(index);
      }
    });
  });
}

function formsDisabled(form) {
  storeFormData(form);
  alert("Unfortunately the server seems to be inaccessible right now, you data has been saved locally and will be uploaded as soon as possible!");
}

function pingAndDisable(form) {
  $.ajax({url: "/ping",
    type: "HEAD",
    timeout:1000,
    statusCode: {
      200: function (res) {
        console.log("server is online, reenable forms");
        uploadLocalStorage();
        if(form != undefined) {
          form.off('submit');
          form.submit();
        }
      },
      400: function (res) {
        console.log("server is offline, switching to local storage");
        if(form != undefined) {
          formsDisabled(form);
        }
      },
      0: function (res) {
        console.log("server is offline, switching to local storage");
        if(form != undefined) {
          formsDisabled(form);
        }
      }              
    }
  });
}


function draw_burndown_charts(chart_data, sprint_duration, sprint_difficulty){
  //Burndown Chart
  var data = chart_data;

  var margin = {top: 30, right: 30, bottom: 50, left: 50},
      width = 600 - margin.left - margin.right,
      height = 400 - margin.top - margin.bottom;


  var x = d3.scale.linear().domain([0, sprint_duration]).range([0, width]),
      y = d3.scale.linear().domain([0, sprint_difficulty]).range([height, 0]);
      xAxis = d3.svg.axis().scale(x).ticks(10)
                .tickFormat(d3.format("d"))
                  .tickSubdivide(0),
      yAxis = d3.svg.axis().scale(y).ticks(10).orient("left")
                .tickFormat(d3.format("d"))
                  .tickSubdivide(0);

  var svg = d3.select("#burndownChart").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom);

  // horizontal lines
  svg.selectAll(".hline").data(d3.range(sprint_difficulty)).enter()
      .append("line")
      .attr("y1", function (d) {
      return d * (height / sprint_difficulty);
  })
      .attr("y2", function (d) {
      return d * (height / sprint_difficulty);
  })
      .attr("x1", function (d) {
      return 0;
  })
      .attr("x2", function (d) {
      return width;
  })
  .style("stroke", "#eee")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


  //vertical lines
  svg.selectAll(".vline").data(d3.range(sprint_duration+1)).enter()
      .append("line")
      .attr("x1", function (d) {
      return d * (width / sprint_duration);
  })
      .attr("x2", function (d) {
      return d * (width / sprint_duration);
  })
      .attr("y1", function (d) {
      return 0;
  })
      .attr("y2", function (d) {
      return height;
  })
  .style("stroke", "#eee")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


  var line = d3.svg.line()
      .x(function (d, i) {
      return x(d[0]);
  })
      .y(function (d) {
      return y(d[1]);
  });

  // Add the x-axis.
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(" + margin.left + "," + (height + margin.top) + ")")
    .call(xAxis);

  // Label y-axis
  svg.append("text")
    .attr("class", "x label")
    .attr("text-anchor", "end")
    .attr("x", width + margin.left)
    .attr("y", height + margin.top + 40)
    .text("Iteration Timeline (days)");

  // Add the y-axis.
  svg.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    .call(yAxis);

  // Label x-axis
  svg.append("text")
    .attr("class", "y label")
    .attr("text-anchor", "end")
    .attr("y", 15)
    .attr("x", -margin.top )
    
    .attr("transform", "rotate(-90)")
    .text("Sum of Task Estimates (difficulty)");

  svg.append("svg:path")
    .attr("d", line(data))
    .attr("class", "data1")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


  //User Contributions Chart for Tasks Done
  var width = 600,
  height = 400,
  radius = Math.min(width, height) / 2;

  var color = d3.scale.ordinal()
      .range(["#98abc5", "#8a89a6", "#7b6888", 
              "#6b486b", "#a05d56", "#d0743c", 
              "#ff8c00", "#88cb9d", "#55b473",
              "#3b7e50", "#84c8d4", "#4fb0c1", 
              "#377b87", "#7696d4", "#3b69c1", 
              "#294987", "#b28ad4", "#9157c1",
              "#653d87", "#cb83ae", "#b44d8b", 
              "#7e3661", "#d4767f", "#c13b48",
              "#872932", "#d6b678", "#c4963e"]);

  var arc = d3.svg.arc()
      .outerRadius(radius - 10)
      .innerRadius(0);

  var pie = d3.layout.pie()
      .sort(null)
      .value(function(d) { return d.num_jobs; });

  var svg = d3.select("#userContributions").append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  var data = JSON.parse($('#data').attr('data-bdc'));
  data.forEach(function(d) {
    d.num_jobs = +d.num_jobs;
  });

  var g = svg.selectAll(".arc")
      .data(pie(data))
      .enter().append("g")
      .attr("class", "arc");

  var count = 0;
  
  g.append("path")
    .attr("d", arc)
    .attr("id", function(d) { return "arc-" + (count++); })
    .style("fill", function(d) {
        return color(d.data.name);
    });

  g.append("text").attr("transform", function(d) {
      return "translate(" + arc.centroid(d) + ")";
  }).attr("dy", ".35em").style("text-anchor", "middle")
  .text(function(d) {
      return d.data.name;
  })

  count = 0;

  var legend = svg.selectAll(".legend")
      .data(data).enter()
      .append("g").attr("class", "legend")
      .attr("legend-id", function(d) {
          return count++;
      })
      .attr("transform", function(d, i) {
          return "translate(-60," + (-70 + i * 20) + ")";
      })
      .on("click", function() {
          console.log("#arc-" + $(this).attr("legend-id"));
          var arc = d3.select("#arc-" + $(this).attr("legend-id"));
          arc.style("opacity", 0.3);
          setTimeout(function() {
              arc.style("opacity", 1);
          }, 1000);
      });
  
  legend.append("rect")
      .attr("x", width / 2)
      .attr("width", 18).attr("height", 18)
      .style("fill", function(d) {
          return color(d.name);
      });

  legend.append("text")
      .attr("x", width / 2)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d) { return d.name; });
}


$(document).ready(function(){
  show_flash_notification();
  setupDataTables();
  setup_delete_links();
  setup_form_dialogs();
  setup_datepicker();

  setup_tabs();

  pingAndDisable();
  $('.form').submit(function (event) {
    event.preventDefault();
    pingAndDisable($(this));
  });

  var appCache = window.applicationCache;
  $(appCache).bind('updateready', function() {
    location.reload(true);
  })

});

  