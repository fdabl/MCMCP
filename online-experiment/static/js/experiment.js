var Experiment = function() {
  /////////////////////////////////
  // (1) Show the two images and let the user decide (onclick event)
  // (2) Call the proposal function and generate a new trial
  // (3) Repeat until done
  // (4) Ask questions
  //
  // To Save: ID, RT, number_chosen, number_not_chosen, quantifier, chosen_side

  var ALL_QUANTIFIER = ['About half', 'Almost all', 'Few', 'Half', 'Less than half',
                        'Many', 'Most', 'Some', 'The majority', 'Very few'];
  var QUANTIFIER = setup_quantifier(ALL_QUANTIFIER);
  var NR_BLOCKS = _.size(QUANTIFIER);

  var DELTA = 20;
  var EPSILON = 0.4;
  var MAX_TRIALS = 200;
  var TRIALS_PER_BLOCK = MAX_TRIALS / NR_BLOCKS;

  var start;
  var sync;
  var num1, num2;
  var quantifier;
  var curtrial = 1;
  var curquant = 1;
  var trialData = [];
  var clicked_left = null;

  var next = function() {

    // we are at the end of a block, so show a pausing screen and update the quantifier
    if ((curtrial - 1) === TRIALS_PER_BLOCK && curquant < NR_BLOCKS) {

      var blocks_left = NR_BLOCKS - curquant;
      psiTurk.showPage('switching.html');
      $('#blocks-left').text(blocks_left + (blocks_left === 1 ? ' block' : ' blocks'));

      curtrial = 1;
      curquant += 1;
      $('#next').on('click', function() {
        psiTurk.showPage('item.html');
        $('#img1').on('click', save);
        $('#img2').on('click', save);
        next();
      });

      // start from random images
      clicked_left = null;
      return;
    }

    if (curtrial <= TRIALS_PER_BLOCK) {
      var nums;

      // this happens only on the first trial
      if (clicked_left === null) {
        nums = make_proposal(null, null, EPSILON, DELTA);

      } else if (clicked_left) {

        // if user clicked left, and num1 is presented on img1,
        // then change the number 2, else change number 1
        nums = sync ? make_proposal(num1, num2, EPSILON, DELTA) :
                      make_proposal(num2, num1, EPSILON, DELTA);

      // clicked right
      } else {
        nums = sync ? make_proposal(num2, num1, EPSILON, DELTA) :
                      make_proposal(num1, num2, EPSILON, DELTA);
      }

      num1 = nums[0];
      num2 = nums[1];

      // if true, means num1 will be presented as img1
      sync = Math.random() > 0.5;

      var img1 = sync ? getImage(num1) : getImage(num2);
      var img2 = sync ? getImage(num2) : getImage(num1);
      var cur_name = names[_.random(0, TRIALS_PER_BLOCK)];

      $('#img1').attr('src', img1);
      $('#img2').attr('src', img2);

      $('.name').text(cur_name);
      quantifier = QUANTIFIER[curquant - 1];
      $('#quantifier').text(quantifier);
      $('#nr-trial').text(curtrial + '/' + TRIALS_PER_BLOCK);

      curtrial += 1;
      start = + new Date();

    } else {
      new Questionnaire().start();
    }
  };

  var save = function(e) {
    var answers;
    e.preventDefault();
    clicked_left = e.target.id === 'img1';

    var RT = + new Date() - start;

    if (clicked_left) {
      number_chosen = sync ? num1 : num2;
      number_not_chosen = number_chosen === num1 ? num2 : num1;
    } else {
      number_chosen = sync ? num2 : num1;
      number_not_chosen = number_chosen === num1 ? num2 : num1;
    }


    trialData = [curtrial - 1, RT, number_chosen, number_not_chosen,
                quantifier, clicked_left ? 'left' : 'right'];

    psiTurk.recordTrialData(trialData);
    next();
  };

  psiTurk.showPage('item.html');
  $('#img1').on('click', save);
  $('#img2').on('click', save);

  next(); // start experiment
};
