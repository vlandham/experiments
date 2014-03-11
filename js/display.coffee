
allData = []
filteringOn = []

vis = null
filters = null

updateFilters = (newFilter) ->
  if newFilter == "all"
    filteringOn = []
  else
    filteringOn = [newFilter]
  filters.selectAll(".btn").classed("btn-default", (d) -> d != newFilter)
  filters.selectAll(".btn").classed("btn-primary", (d) -> d == newFilter)

setupFilters = (data) ->
  allFilters = ["all"]
  data.forEach (d) ->
    d.tags.forEach (f) ->
      if allFilters.indexOf(f) == -1
        allFilters.push(f)
  filters = d3.select("#filters")
    .selectAll(".filter")
    .data(allFilters)

  filters.enter().append("div")
    .attr("class", "filter")
    .append("a")
    .attr("class", "btn btn-default")
    .attr("id", (d) -> d)
    .text((d) -> d)
    .on "click", (d) ->
      updateFilters(d)
      update()
      d3.event.preventDefault()
    updateFilters('all')

setupData = (data) ->
  data.forEach (d) ->
    d
  data

filterData = (data) ->
  console.log(filteringOn)
  if filteringOn.length > 0
    data = data.filter (d) ->
      keep = false
      d.tags.forEach (t) ->
        if filteringOn.indexOf(t) != -1
          keep = true
      keep

  data

update = () ->
  data = filterData(allData)
  exp = vis.selectAll(".experiment")
    .data(data, ((d) -> d.id))

  expE = exp.enter()
    .append("div")
    .attr("class", "experiment")
    .style("opacity", 1e-6)

  expE.append("div")
    .attr("class", "thumb")
    .append("a")
    .attr("href", (d) -> d.url)
    .append("img")
    .attr("src", (d) -> "img/" + d.img)

  expE.append("a")
    .attr("href", (d) -> d.url)
    .append("h2")
    .attr("class", "title")
    .text((d) -> d.name)

  expE.append("p")
    .attr("class", "description")
    .text((d) -> d.description)

  expE.transition()
    .duration(600)
    .style("opacity", 1.0)

  exp.exit().transition()
    .duration(600)
    .style("opacity", 1e-6)
    .remove()


display = (error, data) ->
  allData = setupData(data)
  setupFilters(allData)
  vis = d3.select("#display")

  update()

$ ->
  d3.json("data/data.json", display)

