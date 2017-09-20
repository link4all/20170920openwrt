var downPie,upPie;

function pieChart(){
  var _chart = {},
      _svg,
      _pieG,
      _textG,
      _outerR,
      _innerR,
      _data,
      _arc = d3.svg.arc()
        .outerRadius(120)
        .innerRadius(72),
      _pie = d3.layout.pie()
        .sort(null)
        .value(function(d){return d['data'];});

  _chart.container = function(container){
    _container = container;
    return _chart;
  };
  _chart.data = function(data){
    _data = data;
    return _chart;
  };
  _chart.render = function(_container){
    if(!_svg){
      _svg = d3.select('#' + _container)
          .append('svg')
            .attr({'viewBox': '0,0,300,300'});
    }

    renderSlices(_pie,_arc,_container);
    renderText();

    return _chart;
  };
  _chart.reset = function(){
    $('#' + _container).empty();
    return _chart;
  };

  _chart.renderLabels = function(_container){
    var container = d3.select('#' + _container + '-label-container').selectAll('div.pie-labels')
            .data(_data);

    container.exit().remove();

    container.html(function(d){ return d.label; })

    container.enter()
        .append('div')
            .classed('pie-labels',true)
            .attr('data-label',function(d,i){ return _container + '_' + i; })
            .html(function(d){ return d.label; })
            .style('border-bottom',function(d,i){ return '6px solid hsl(' + (20*(i+1)) + ',80%,50%)';})

    d3.select('#' + _container + '-label-container').selectAll('div.pie-labels')
      .on('mouseenter',function(d,i){
        d3.select(this).style({
          'background-color':'hsl(' + (20*(i+1)) + ',80%,50%)',
          'color': 'white'
        });
        d3.select('[data-index="' + _container + '_' + i + '"]').attr('transform','scale(1.15,1.15)');
        showDetails(d,_container);
      })
      .on('mouseleave',function(d,i){
        d3.select(this).style({'background-color':'transparent','color':'#333'})
        d3.select('[data-index="' + _container + '_' + i + '"]').attr('transform','scale(1,1)');
        hideDetails(_container);
      });
      return _chart;
  };
  function renderSlices(pie,arc,_container){
    if(!_pieG){
      _pieG = _svg.append('g')
          .attr('transform','translate(150,150)')
          .classed('pie',true);
    }
    var slices = _pieG.selectAll('path')
        .data(pie(_data));
    slices.exit().remove();

    slices.transition().duration(1000)
        .attrTween('d',function(d){
          var currentArc = this.__current__;

          if(!currentArc){
            currentArc = {startAngle: 0, endAngle: 0};
          }
          var interpolate = d3.interpolate(currentArc,d);
          this.__current__ = interpolate(1);

          return function(t){
            return arc(interpolate(t));
          };
        });

    slices.enter().append('path')
        .attr('fill',function(d,i){
          return 'hsl(' + (20*(i+1)) + ',80%,50%)';
        })
        .attr('opacity',0.72)
        .attr('data-index',function(d,i){ return _container + '_' + i; })
        .attr('stroke','white')
        .attr('stroke-width',1.2)
        .transition().duration(1000)
        .attrTween('d',function(d){
          var currentArc = this.__current__;

          if(!currentArc){
            currentArc = {startAngle: 0, endAngle: 0};
          }
          var interpolate = d3.interpolate(currentArc,d);
          this.__current__ = interpolate(1);

          return function(t){
            return arc(interpolate(t));
          };
        });
    d3.select('#' + _container).selectAll('path')
      .on('mouseenter',function(d,i){
        d3.select(this).attr('transform','scale(1.15,1.15)');
        d3.select('[data-label="' + _container + '_' + i + '"]')
          .style({
              'background-color':'hsl(' + (20*(i+1)) + ',80%,50%)',
              'color': 'white'
            })
        showDetails(_data[i],_container);
      })
      .on('click',function(d,i){
        d3.select(this).attr('transform','scale(1.15,1.15)');
        d3.select('[data-label="' + _container + '_' + i + '"]')
          .style({
              'background-color':'hsl(' + (20*(i+1)) + ',80%,50%)',
              'color': 'white'
            })
        showDetails(_data[i],_container);
      })
      .on('mouseleave',function(d,i){
        d3.select(this).attr('transform','scale(1,1)');
        d3.select('[data-label="' + _container + '_' + i + '"]')
              .style({'background-color':'transparent','color':'#333'})
        hideDetails(_container);
      });
  }
  function renderText(){
    if(!_textG){
      _textG = _svg.append('g')
          .classed('label-detailed',true)
          .attr('transform','translate(150,150)');
    }
    if(!_textG.select('text.type')[0][0]){
      _textG.append('text')
          .html(_container)
          .classed('type',true)
          .attr({
            'dy': 0,
            'text-anchor': 'middle',
            'font-size': '18px',
            'opacity': '0.72'
          });
    }
  }
  function showDetails(data,_container){
    d3.select('#' + _container).selectAll('.label-detailed').select('.type')
        .transition().duration(500)
          .attr('dy',-20);
    d3.select('#' + _container).selectAll('.label-detailed').selectAll('.desc')
        .transition().duration(500)
          .attr({
            'dy': 50,
            'opacity': 0
          })
          .remove();
	var textG = d3.select('#' + _container).select('.label-detailed');
	textG.append('text')
	  .html(data['label'])
	  .classed('desc',true);
	textG.append('text')
	  .classed('desc',true)
	  .html(data['qos'] + '|' + data['pct'])
	  .attr('dy', 20);
	textG.selectAll('text.desc')
	  .attr({
	    'text-anchor': 'middle',
	    'font-size': '14px',
	    'opacity': '0.72'
	  });
  }
  function hideDetails(_container){
    d3.select('#' + _container).selectAll('.label-detailed').select('.type').transition().duration(500)
      .attr('dy',0);
    d3.select('#' + _container).selectAll('.label-detailed').selectAll('.desc')
      .attr('fill','#ccc')
      .transition().duration(500)
      .attr({
        'dy': 50,
        'opacity': 0,
        'transform': 'scale(0.1,0.1)'
      }).remove();
  }

  return _chart;
}

function initPies(down_data,up_data){
  downPie = pieChart()
    .container('down')
    .reset()
    .data(down_data)
    .render('down')
    .renderLabels('down');
  upPie = pieChart()
    .container('up')
    .reset()
    .data(up_data)
    .render('up')
    .renderLabels('up');
}


function updatePies(down_data,up_data){
  downPie.data(down_data).container('down').render('down').renderLabels('down');
  upPie.data(up_data).container('up').render('up').renderLabels('up');
}