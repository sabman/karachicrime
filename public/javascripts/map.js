$(function() {
  var mapel = $('#canvas')
  if(mapel.length == 0) return
  
  var path = $(document.body).data().path,
      po = org.polymaps,
      lightstyle = 5870,
      darkstyle  = 1960,
      svg = po.svg('svg'),
      map = po.map()
      .container(mapel[0].appendChild(svg))
      .center({lat: 24.86, lon: 67.01})
      .zoom(13)
      .zoomRange([9,18])
      .add(po.interact())
      .add(po.hash())
      
  map.add(po.image()
      .url(po.url("http://{S}tile.cloudmade.com"
      + "/16d73702b7824b57830171b5da5c3c85" // http://cloudmade.com/register
      + "/" + lightstyle + "/256/{Z}/{X}/{Y}.png")
      .hosts(["a.", "b.", "c.", ""])));

  // map.add(po.compass()
  //   .zoom('small')
  //   .position('top-left')
  //   .radius(30)
  //   .pan('none'))
    
  $('.compass').click(togglecrimes)   
   
   $.getJSON(document.location.pathname + '.geojson', addDataLayer) 
   
   function addDataLayer(data) {
     // Likely a Neighborhood if we have a Polygon.  Center the map to the 
     // neighborhoods first point
     var first = data.features[0],
         type = first.geometry.type.toLowerCase()
     if(type == 'polygon' || type == 'multipolygon') {
       if(type == 'multipolygon')
        var ll = first.geometry.coordinates[0][0][0]
       else
         var ll = first.geometry.coordinates[0][0] 
       
       map.center({lat: ll[1], lon: ll[0]})
       map.zoom(14)
       
       
       if(path == 'neighborhoods-show') {
         $.getJSON(document.location.pathname + '/crimes.geojson', addDataLayer)
       }
       
     } else {
       $(document).trigger('crimes.loaded', data)
     }
     
     map.add(po.geoJson()
       .features(data.features)
       .on('load', load))
   }
  
  /**
   * Fullscreen support
   */
  var resizer = $('<span />').addClass('resizer').text('`'),
      width = mapel.width(),
      height = mapel.height(),
      body   = $(document.body),
      logo   = $('<img />')
        .attr('src', '/images/logo-small.png')
        .addClass('fslogo'),
      hdr    = $('header#top .wrap-inner')
  
  $(document).keyup(function(e) {
    if (e.keyCode == 27) { $('.resizer').click(); }   // esc
  })
      
  resizer.bind('click', function(event) {
    if(body.hasClass('fullscreen')) {      
      _gaq.push(['_trackEvent', 'Map', 'Fullscreen Close', document.title]);
      body.removeClass('fullscreen')
      mapel.find('header').show()
      mapel.css({position: 'static', width: width, height: height, 'z-index': 'inherit'})
      logo.remove()      
    } else {
      _gaq.push(['_trackEvent', 'Map', 'Fullscreen Zoom', document.title]);
      body.addClass('fullscreen')
      mapel.find('header').hide()
      mapel.css({position: 'fixed', top: 0, right: 0, width: '100%', height: '100%', 'z-index': 9999})
      mapel.find('svg').css({ width: '100%', height: '100%'})
      mapel.append(logo.remove())
    }
    
    map.resize()
  })
  
  mapel.prepend(resizer)
  
  function load(e) {  
    var counts = {}  
    $.each(e.features, function() {
      var type = this.data.geometry.type.toLowerCase()
      if(type == 'polygon' || type == 'multipolygon') {
        renderNeighborhood(this)
      } else {
        var el = this.element,
            $el   = $(el),
            $cir  = $(el.firstChild),
            text  = po.svg('text'),
            props = this.data.properties,
            // time  = Date.parse(props.reported_at),
            // hours = time.getHours(),
            check = $('span.check[data-code=' + props.code + ']'),
            inact = check.hasClass('inactive')
      
        if(!counts[props.code]) counts[props.code] = 0
        counts[props.code]++
      
        if(inact)
          $el.addSVGClass('inactive')

        $el.addSVGClass(props.code)
        $cir.addSVGClass('circle')
        $cir.addSVGClass(props.code)      
        $cir[0].setAttribute("r", 12)

        $el.bind('click', {props: props, geo: this.data.geometry}, onPointClick)      
            
        text.setAttribute("text-anchor", "middle")
        text.setAttribute("dy", ".35em")
        text.appendChild(document.createTextNode(props.code))
      
        el.appendChild(text)
      }
    })
        
    $('#sbar li.off').each(function() {
      var el = $(this),
          cnt = el.find('span.count')
      if(cnt.length == 0) {
        var check = el.find('span.check'),
            code = check.attr('data-code')
      
        if(!counts[code]) counts[code] = 0
      
        check.parent()
          .append($('<span class="count" />')
          .text(counts[code]))
      }
    })
  
    $('#map').bind('map.togglecrimes', togglecrimes)
    
      if($('#map .compass').length == 0)
        map.add(po.compass()
          .zoom('small')
          .position('top-left')
          .radius(30)
          .pan('none'))
  }
  
  function renderNeighborhood(nhood) {
    var $el = $(nhood.element)
    
    $el.addSVGClass('nhood')
  }
  
  /**
   * Check the state of crimes in the sidebar, assigning the proper class 
   * depending if they are active or inactive
   */
  function togglecrimes(event, from) {
    $('#sbar span.check').each(function() {
      var check = $(this),
          code  = check.attr('data-code'),
          klass = this.getAttribute('class'),
          nodes = $('#canvas g.' + code)

      if(klass.indexOf('inactive') != -1) {
        nodes.each(function() { 
          //$(this).unbind('click', onPointClick)      
          $(this).addSVGClass('inactive') 
        })
      } else {        
        nodes.each(function() { 
          //$(this).unbind('click', onPointClick)      
          $(this).removeSVGClass('inactive') 
        })
      }
    })
  }
  
   var onPointClick = function(event) {
    var coor = event.data.geo.coordinates,
        props = event.data.props
        
    mapel.maptip(this)
      .map(map)
      .data(props)
      .location({lat: coor[1], lon: coor[0]})
      .top(function(tip) {
        var radius = tip.target.getAttribute('r'),
            point = tip.props.map.locationPoint(this.props.location)
        
        return parseFloat(point.y - 30)
      }).left(function(tip) {
        var radius = tip.target.getAttribute('r'),
            point = tip.props.map.locationPoint(this.props.location)
        
        return parseFloat(point.x + (radius / 2.0) + 20)
      }).content(function(d) {
        var self = this,
            props = d,
            cnt = $('<div/>'),
            hdr = $('<h2/>'),
            bdy = $('<p/>')
      
        // Try to reuse what's already on the page.
        var check = $('#sbar span[data-code=' + props.code + ']'),
            ctype = check.next().clone(),
            otype = check.closest('li.group').attr('data-code'),
            close = $('<span/>').addClass('close').text('*')
      
        // Couldn't find the right info on the page, make a request for it.
        if(ctype.length == 0) {
          $.getJSON('/offenses/' + d.offense_id + '.json', function(data) {
            otype = data.type.name.toLowerCase().substring(0,2)
            hdr.append($('<span/>').addClass('badge').text('E').attr('data-code', otype))
              .append($('<a/>').attr('href', '/offenses/' + data.permalink).text(data.name))
              .append(close)
              .addClass(otype)
          })
         ctype = $('#sbar h1').clone()
        } else {
         hdr.append($('<span/>').addClass('badge').text('E').attr('data-code', otype))
           .append(ctype)
           .append(close)
           .addClass(otype) 
        }
      
        bdy.text(props.address)
        bdy.append($('<span />')
          .addClass('date')
          .text(Date.parse(props.reported_at).toString('dddd, MMM dS @ h:mm tt')))
        
        cnt.append($('<div/>').addClass('nub'))
        cnt.append(hdr).append(bdy) 
        
        close.click(function() {
          self.hide()
        })   
    
        return cnt  
      }).render()
    }
})
