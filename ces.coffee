
$sideBar = $('#sidebar');
$openOrders = $('#openorders');
$headers = $('#openorders_wrapper thead tr')

$('th:eq(0)',$headers).text 'Type & Time'
$('th:eq(1)',$headers).text 'Price'
$('th:eq(2)',$headers).text 'Difference'

document.addEventListener "DOMNodeInserted", ->

  $('tbody tr', $openOrders).each ->
    $this = $(this)
    $order = $('td:nth-child(1)',$this)
    $price = $('td:nth-child(2)',$this)
    $quantity = $('td:nth-child(3)',$this)
    $total = $('td:nth-child(4)',$this)
    $action = $('td:nth-child(5)',$this)
      
    # parse order
    orderData = $order.text().split('  ')
    dateMoment = moment(orderData[0].trim(), "YYYY-MM-DD HH:mm:ss")
    $market = $("a:contains('#{orderData[4]}')",$sideBar)

    order =
      created : 
        date: dateMoment.toDate()
        human: dateMoment.fromNow()
        formatted: dateMoment.format("ddd D/M, hh:mm")
      type : orderData[3]
      glyph: if orderData[3] is 'Buy' then '◀' else '▶'
      price : parseFloat $price.text()
      quantity : parseFloat $quantity.text()
      total : parseFloat $total.text()
      market : 
        x : orderData[4].split('/')[1]
        y : orderData[4].split('/')[0]
        name: orderData[4]
        price : parseFloat $(".pull-right", $market).text()
        url : $market.attr('href')

    
    order.diff = (order.price - order.market.price).toFixed(8)
    order.diffPercent = ((Math.abs(order.diff) / order.price) * 100).toFixed(2)
    

    # DOM Stuff
    $order.html """
      <div>#{order.glyph} #{order.type} <b>#{order.market.name}</b></div>  
      <div>#{order.created.human}, #{order.created.formatted}</div>
    """

    $price.html """
      <div>#{order.price} #{order.market.x}</div>  
      <div>#{order.market.price} Now</div>
    """

    $quantity.html """
      <div>#{order.diff} Diff</div>
      <div>#{order.diffPercent} %</div>      
    """

    $total.html """
      <div>#{order.quantity}  #{order.market.y}</div>
      <div>#{order.total} #{order.market.x}</div>  
    """

    $action.append "<div><a href='#{order.market.url}'>Show Market</a></div>"

    if order.type is 'Buy' then $this.css('color','green') else $this.css('color','red')     

    $('#openorders_wrapper .dataTables_scrollBody').height($openOrders.height()+50)

, false