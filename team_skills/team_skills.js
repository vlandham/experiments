var margin = {
  top: 20,
  right: 220,
  bottom: 30,
  left: 0
};

var width = 800;
var height = 600;

var svg;

var x = d3.scale.ordinal()
  .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
  .rangeRound([height, 0]);

var pallates = {
  "one":["#D53E4F", "#FC8D59", "#FEE08B", "#E6F598", "#99D594", "#3288BD"],
  "three":['rgb(166,206,227)','rgb(31,120,180)','rgb(178,223,138)','rgb(51,160,44)','rgb(251,154,153)','rgb(227,26,28)'].reverse(),
  "two":['rgb(102,194,165)','rgb(252,141,98)','rgb(141,160,203)','rgb(231,138,195)','rgb(166,216,84)','rgb(255,217,47)'],
  "four":["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]
}

var teamMember;

var color = d3.scale.ordinal()
  .range(["#D53E4F", "#FC8D59", "#FEE08B", "#E6F598", "#99D594", "#3288BD"]);

updateColors = function(newId) {
  colors = pallates[newId];
  color.range(colors);

  svg.selectAll(".teamMember").selectAll("rect")
    .transition()
    .duration(500)
    .attr("fill", function(d) {return color(d.name);});
}

setupColors = function() {
  colors = d3.map(pallates).entries();
  console.log(colors);
  d3.select("#colors").selectAll(".pal").data(colors)
    .enter().append("div")
    .attr("class", "pal")
    .on("click", function(d) { updateColors(d.key)})
    .selectAll(".col").data(function(d) {return d.value}).enter()
    .append("div")
    .attr("class", "col")
    .style("width", "10px")
    .style("height", "15px")
    .style("background-color", function(d) { return d;});

}


  // .range(['rgb(102,194,165)','rgb(252,141,98)','rgb(141,160,203)','rgb(231,138,195)','rgb(166,216,84)','rgb(255,217,47)']);
  // .range(['rgb(166,206,227)','rgb(31,120,180)','rgb(178,223,138)','rgb(51,160,44)','rgb(251,154,153)','rgb(227,26,28)'].reverse());
  // .range(["#FFFFD4", "#FEE391", "#FEC44F", "#FE9929", "#D95F0E", "#993404"].reverse());
  // .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

setupColors();

var xAxis = d3.svg.axis()
  .scale(x)
  .orient("bottom");

svg = d3.select("#chart").append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.csv("data.csv", function(error, data) {
  data = data.filter(function(d) {return d["TeamMember"] != "Jim S";});
  console.log(data);
  color.domain(d3.keys(data[0]).filter(function(key) {
    return key !== "TeamMember" && key !== "order";
  }));

  data.forEach(function(d) {
    var y0 = 0;
    d.skills = color.domain().map(function(name) {
      return {
        name: name,
        y0: y0,
        y1: y0 += +d[name]
      };
    });
    d.skills.forEach(function(d) {
      d.y0 /= y0;
      d.y1 /= y0;
    });
  });

  data.sort(function(a, b) {
    return b.skills[0].y1 - a.skills[0].y1;
  });

  x.domain(data.map(function(d) {
    return d.TeamMember;
  }));

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  teamMember = svg.selectAll(".teamMember")
    .data(data)
    .enter().append("g")
    .attr("class", "teamMember")
    .attr("transform", function(d) {
      return "translate(" + x(d.TeamMember) + ",0)";
    });

  teamMember.selectAll("rect")
    .data(function(d) {
      return d.skills;
    })
    .enter().append("rect")
    .attr("width", x.rangeBand())
    .attr("y", function(d) {
      return y(d.y1);
    })
    .attr("height", function(d) {
      return y(d.y0) - y(d.y1);
    })
    .attr("fill", function(d) {
      return color(d.name);
    });

  var legend = svg.select(".teamMember:last-child").selectAll(".legend")
    .data(function(d) {
      return d.skills;
    })
    .enter().append("g")
    .attr("class", "legend")
    .attr("transform", function(d) {
      return "translate(" + (x.rangeBand() + 5) + "," + y((d.y0 + d.y1) / 2) + ")";
    });

  legend.append("line")
    .attr("x2", 10);

  legend.append("text")
    .attr("x", 13)
    .attr("dy", ".35em")
    .text(function(d) {
      return d.name;
    });

});
