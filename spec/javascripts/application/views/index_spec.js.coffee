describe 'App.Views.Auth.Index', () ->

  beforeEach () ->
    @view = new App.Views.Auth.Index()
    @view.render()

  describe 'validations', () ->
    beforeEach () ->
      sinon.spy(@view, "login")

    it 'prevents login unless all fields are filled', () ->
      @view.$el.find("#login_form").trigger("submit")
      setTimeout () =>
        expect(@view.login).not.to.have.been.called
      , 500

    it 'tries to login if all fields are correctly set', () ->
      @view.$el.find("#email").val("someemail@email.com")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#login_form button").click()
      setTimeout () =>
        expect(@view.login).to.have.been.calledOnce
      , 500

    it 'prevents login if email is invalid', () ->
      @view.$el.find("#email").val("invalid")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#login_form button").click()
      setTimeout () =>
        expect(@view.login).not.to.have.been.called
      , 500

  describe 'login', () ->

    before () ->
      @dfd = $.Deferred()
      sinon.stub(jQuery, "post").returns(@dfd);
      @userDfd = $.Deferred()
      sinon.stub(App.Collections.Users.prototype, "fetch").returns(@userDfd)
      @view.$el.find("#email").val("someemail@email.com")
      @view.$el.find("#password").val("somepassword")
      @view.$el.find("#login_form button").click()

    it 'shows an error when login fails', () ->
      setTimeout () =>
        @dfd.reject()
        expect(@$el.find(".error").html()).to.equal("Login failed!")
      , 500

    it 'logs the user in and redirects to runs', () ->
      authToken = {
        token: 'someToken',
        expires_in: moment().add(1, "day")
      }
      user = {
        id: 1,
        name: 'john'
      }
      setTimeout () =>
        @dfd.resolve(authToken)
        @userDfd.resolve(user)
        expect(localStorage.getItem("authToken")).to.equal(JSON.stringify(authToken))
        expect(localStorage.getItem("currentUser")).to.equal(JSON.stringify(user))
        expect(Backbone.history.navigate).to.have.been.calledOnce.and
           .to.have.been.calledWith("/runs", trigger: true)
      , 500
