describe "App.Mixins", () ->

  describe 'they provide common functions', () ->

    beforeEach () ->
      @obj = {}
      _.extend @obj, App.Mixins

    afterEach () ->
      localStorage.clear()

    it 'provides authToken getter', () ->
      expect(@obj.authToken).to.be.a("function")

    it 'provides currentUser getter', () ->
      expect(@obj.currentUser).to.be.a("function")

    describe 'authToken', () ->

      it 'returns null if authToken is not set', () ->
        expect(@obj.authToken()).to.be.null

      it 'returns the authToken if it is set', () ->
        token = {token: "token"}
        localStorage.setItem("authToken", JSON.stringify({token: "token"}))
        expect(@obj.authToken()).to.equal(token.token)

    describe 'currentUser', () ->

      it 'returns null if currentUser is not set', () ->
        expect(@obj.currentUser()).to.be.null

      it 'returns the currentUser model if it is set', () ->
        userPayload = {name: "name"}
        localStorage.setItem("currentUser", JSON.stringify(userPayload))
        expect(JSON.stringify(@obj.currentUser().toJSON())).to.equal(JSON.stringify(userPayload))
