var setupTrials = function(items) {
  return items;
};


var setup_quantifier = function(all_quants) {
  var should_not_occur = { 'About half': 'Half',
                           'Half'      : 'About half',
                           'Very few'  : 'Few',
                           'Few'       : 'Very few',
                           'Almost all': 'All',
                           'All'       : 'Almost all' };

  var select = _.shuffle(all_quants).slice(0, 4);
  var is_okay = false;

  while (!is_okay) {
    is_okay = true;
    select = _.shuffle(select);

    for (i = 0; i < 2; i++) {
      var current = select[i];
      var next = select[i+1];

      if (should_not_occur[current] === next) {
        is_okay = false;
      }
    }
  }

  return select;
};


var test_quantifier = function(select) {
  var should_not_occur = { 'About half': 'Half',
                           'Half'      : 'About half',
                           'Very few'  : 'Few',
                           'Few'       : 'Very few',
                           'Almost all': 'All',
                           'All'       : 'Almost all' };

  var correct = true;
  for (i = 0; i < 2; i++) {
    var current = select[i];
    var next = select[i+1];

    if (should_not_occur[current] === next) {
      correct = false;
    }
  }

  return correct;
};



var create_array = function(start, end) {
  var arr = [];
  var i = start;
  while (i <= end) {
    arr.push(i);
    i += 1;
  }
  return arr;
};


var without = function(arr1, arr2) {
  var res = [];
  var n = _.size(arr1);

  for (i = 0; i < n; i++) {
    var el = arr1[i];
    if (arr2.indexOf(el) === -1) {
      res.push(el);
    }
  }

  return res;
};


var make_proposal = function(num1, num2, epsilon, delta) {
  // returns an array with num1 and num2 (number of red dots of left and right image)
  // changes num2 based on num1 if neither num1 nor num2 are null
  var x, low, up, interval;

  i = 0;
  var points = create_array(0, 432);

  // change num2 based on the value of num1
  x = num1;
  low = x - delta;
  up = x + delta;

  if (num1 === null && num2 === null) {
    var f = _.first(points);
    var l = _.last(points);

    num1 = _.random(f, l);
    num2 = _.random(f, l);

    while (num1 === num2) {
      num1 = _.random(f, l);
      num2 = _.random(f, l);
    }

    return [num1, num2];
  }

  if (Math.random() > epsilon) {

    if (low >= 0 && up <= 432) {
      interval = points.slice(low, up + 1);

    } else if (low <= 0) {

      lower_interval = points.slice(432 + low, 432 + 1).concat(create_array(0, x));
      upper_interval = create_array(x, up);
      interval = lower_interval.concat(upper_interval);

    } else {

      upper_interval = points.slice(0, up - 432 + 1).concat(create_array(x, 432));
      lower_interval = create_array(low, x);
      interval = upper_interval.concat(lower_interval);

    }

  } else {

    if (low >= 0 && up <= 432) {
      interval = without(points, create_array(low, up));

    } else if (low <= 0) {

      lower_interval = points.slice(432 + low, 432 + 1).concat(create_array(0, x));
      upper_interval = create_array(x, up);
      interval = lower_interval.concat(upper_interval);
      interval = without(points, interval);

    } else {

      upper_interval = points.slice(1, up - 432 + 1).concat(create_array(x, 432));
      lower_interval = create_array(x, up);
      interval = lower_interval.concat(upper_interval);
      interval = without(points, interval);
    }

  }

  var proposal = interval[_.random(0, _.size(interval) - 1)];
  return [num1, proposal];

};


var getImage = function(nbr_red_dots) {
  var letters = 'abcdefghij';
  var image_code = nbr_red_dots + 'red_dots_' + letters[_.random(0, 9)] + '.png';
  return '/static/images/' + image_code;
};
