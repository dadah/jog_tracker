class App.Views.Reports.Index extends App.Views.Reports.Base

  initialValues: ->
    0

  buildChart: ->
    @collection.fetch(reset: true, data: {user_id: @userId, starts_at: @startDate.format("YYYY-MM-DD")}).done ()=>
      @collection.each (model) =>
        currDate = moment(model.get("run_date"))
        currDate.startOf("week")
        @data[currDate.format("YYYY-MM-DD")] += model.get("distance")
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
        title: 'Distance (in meters)'
        viewWindow:
          min:0

    dataTable.addColumn('date', 'X')
    dataTable.addColumn('number', 'User')
    pairs = _.pairs(@data)
    _.each pairs, (pair) ->
      pair[0] = moment(pair[0]).toDate()

    dataTable.addRows(pairs)
    chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    chart.draw(dataTable, options);
