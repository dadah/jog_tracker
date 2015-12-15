class App.Views.Reports.Speed extends App.Views.Reports.Base

  initialValues: ->
    { distance: 0, run_time: 0 }

  buildChart: ->
    @collection.fetch(reset: true, data: {user_id: @userId, starts_at: @startDate.format("YYYY-MM-DD")}).done ()=>
      @collection.each (model) =>
        currDate = moment(model.get("run_date"))
        currDate.startOf("week")
        @data[currDate.format("YYYY-MM-DD")].distance += model.get("distance")
        @data[currDate.format("YYYY-MM-DD")].run_time += model.get("run_time")
      @drawChart()

  drawChart: ->
    dataTable = new google.visualization.DataTable()
    options =
      legend:
        position: 'none'
      height:400
      hAxis:
        title: 'Week'
        format: "'week' w 'of' yyy 'starting on' d MMM"
      vAxis:
        title: 'Average speed (in km/hour)'
        viewWindow:
          min:0

    dataTable.addColumn('date', 'X')
    dataTable.addColumn('number', 'User')

    pairs = _.pairs(@data)

    _.each pairs, (pair) ->
      pair[0] = moment(pair[0]).toDate()
      if pair[1].run_time > 0
        pair[1] = parseFloat(((pair[1].distance/1000)/((pair[1].run_time/60)/60)).toFixed(2))
      else
        pair[1] = 0
    dataTable.addRows(pairs)
    chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    chart.draw(dataTable, options);
