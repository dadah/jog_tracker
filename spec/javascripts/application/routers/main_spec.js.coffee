describe "App.Routers.Main", () ->

  opts = { trigger: true, replace: true }

  beforeEach () ->
    @router = new App.Routers.Main()
    @routerSpy = sinon.spy()
    @router.on "route", @routerSpy

  describe 'routing', () ->
    it "can route to login", () ->
      @router.navigate("", opts)
      expect(@routerSpy)
        .to.have.been.calledOnce.and
        .to.have.been.calledWith("index", [null])

    it "can route to signup", () ->
      @router.navigate("signup", opts)
      expect(@routerSpy)
        .to.have.been.calledOnce.and
        .to.have.been.calledWith("signup", [null])

    describe 'to routes that require login', () ->

      afterEach () ->
        expect(@routerSpy)
          .to.have.been.calledWith("index", [null])

      it "routes to runs but redirects to login", () ->
        @router.navigate("runs", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("runs", [null])

      it "routes to runs/new but redirects to login", () ->
        @router.navigate("runs/new", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("newRun", [null])

      it "routes to runs/:id/edit but redirects to login", () ->
        @router.navigate("runs/1/edit", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("editRun", ["1", null])

      it "routes to users but redirects to login", () ->
        @router.navigate("users", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("users", [null])

      it "routes to runs/new but redirects to login", () ->
        @router.navigate("users/new", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("newUser", [null])

      it "routes to users/:id/edit but redirects to login", () ->
        @router.navigate("users/1/edit", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("editUser", ["1", null])

      it "routes to account but redirects to login", () ->
        @router.navigate("account", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("account", [null])

      it "routes to reports/distance but redirects to login", () ->
        @router.navigate("reports/distance", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("distanceReport", [null])

      it "routes to reports/speed but redirects to login", () ->
        @router.navigate("reports/distance", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("distanceReport", [null])

    describe 'after login', () ->
      beforeEach () ->
        @sandbox = sinon.sandbox.create()
        @sandbox.mock(App.Views.Menu.Index)
        @sandbox.stub(App.Views.Menu.Index.prototype)
        App.Views.Menu.Index.prototype.render.returns({ $el: null });
        sinon.stub(@router, "authToken").returns("test")
        sinon.stub(@router, "swapView").returns("test")

      afterEach () ->
        @sandbox.restore()

      it "routes runs to runs and creates the menu", ->
        expect(@router.menuView).to.be.null
        @router.navigate("runs", opts)
        expect(@routerSpy)
          .to.have.been.calledOnce.and
          .to.have.been.calledWith("runs", [null])
        expect(@router.menuView).to.be.an("object")

      it "routes signup but redirects to runs", ->
        @router.navigate("signup", opts)
        expect(@routerSpy)
          .to.have.been.calledTwice.and
          .to.have.been.calledWith("signup", [null]).and
          .to.have.been.calledWith("runs", [null])

      describe 'when menu view is set', ->
        it 'routes to users but does not create the menu', ->
          @router.menuView = true
          @router.navigate("users", opts)
          expect(App.Views.Menu.Index.prototype.render).not.to.have.been.called
          expect(@routerSpy)
            .to.have.been.calledOnce.and
            .to.have.been.calledWith("users", [null])
