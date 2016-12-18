var Questionnaire = function() {

  this.save_data = function(language) {
    var comments = $('#comment').val();
    psiTurk.recordTrialData({'phase':'postquestionnaire', 'status':'submit'});
    psiTurk.recordTrialData([language]);
    psiTurk.recordTrialData([comments]);
    psiTurk.recordUnstructuredData('language', language);
    psiTurk.recordUnstructuredData('comments', comments);

    $('select').each(function(i, val) {
      psiTurk.recordTrialData([this.value]);
    });

  };

  this.record_responses = function() {
    // save their native language
    var language = $('#language').val();
    this.LANGUAGE = false;
    
    $('select').each(function(i, val) {
      psiTurk.recordUnstructuredData(this.id, this.value);
    });

    if (language === '') {
      alert('Please indicate your native language.');
      $('#language').focus();
      return false;
    } else {
        this.LANGUAGE = true;
        this.save_data(language);
    }
  };

  this.prompt_resubmit = function() {
    var error = ["<h1>Oops!</h1><p>Something went wrong submitting your HIT.",
                 "This might happen if you lose your internet connection.",
                 "Press the button to resubmit.</p><button id='resubmit'>Resubmit</button>"].join(' ');
    $('body').html(error);
    $('#resubmit').on('click', _.bind(this.resubmit, this));
  };

  this.resubmit = function() {
    $('body').html('<h1>Trying to resubmit...</h1>');
    var reprompt = setTimeout(_.bind(this.prompt_resubmit, this), 10000);
    if (!this.LANGUAGE) this.save_data('NA');

    var self = this;
    psiTurk.saveData({
      success: function() {
        clearInterval(reprompt); 
        psiTurk.completeHIT();
      },
      error: _.bind(self.prompt_resubmit, self)
    });
  };

  this.start = function() {
    psiTurk.showPage('postquestionnaire.html');

    var self = this;
    $('#next').on('click', function() {
      // bahaha, this is just clever (or sad?)
      if (self.record_responses() === false) {
        return new Questionnaire().start();
      }
      psiTurk.saveData({
        success: psiTurk.completeHIT,
        error: _.bind(self.prompt_resubmit, self)
      });
    });
  };
};
