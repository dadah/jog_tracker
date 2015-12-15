describe 'App.Views.Auth.Signup', () ->

  beforeEach () ->
    @view = new App.Views.Auth.Signup()
    @view.render()

  describe 'validations', () ->
    beforeEach () ->
      sinon.spy(@view, "signup")

    it 'prevents signup unless all fields are filled', () ->
      @view.$el.find("#signup_form").trigger("submit")
      setTimeout () =>
        expect(@view.signup).not.to.have.been.called
      , 500

    it 'tries to signup if all fields are correctly set', () ->
      @view.$el.find("#name").val("John")
      @view.$el.find("#email").val("someemail@email.com")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#signup_form button").click()
      setTimeout () =>
        expect(@view.signup).to.have.been.calledOnce
      , 500

    it 'prevents signup if email is invalid', () ->
      @view.$el.find("#name").val("John")
      @view.$el.find("#email").val("invalid")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#signup_form #signup_button").click()
      setTimeout () =>
        expect(@view.signup).not.to.have.been.called
      , 500

  describe 'signup', () ->

    before () ->
      @dfd = $.Deferred()
      sinon.stub(App.Models.User.prototype, "save").returns(@dfd);
      @view.$el.find("#name").val("John")
      @view.$el.find("#email").val("someemail@email.com")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#signup_form button").click()

    it 'shows an error when signup fails', () ->
      setTimeout () =>
        @dfd.reject(reponseJSON: { response: "somemessage" })
        expect(@$el.find(".error").html()).to.equal("Could not create the account! somemessage")
      , 500

    it 'creates the user and redirects to login', () ->
      setTimeout () =>
        @dfd.resolve()
        expect(Backbone.history.navigate).to.have.been.calledOnce.and
           .to.have.been.calledWith("/", trigger: true)
      , 500
