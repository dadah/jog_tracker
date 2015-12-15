describe "Namespace", () ->
  it("provides the 'App' object", () ->
    expect(App).to.be.an("object")

    expect(App).to.include.keys(
      "Mixins",
      "Helpers",
      "Models",
      "Collections",
      "Routers",
      "Views"
    )
  )

  it "provides the 'app' object", () ->
    expect(App).to.be.an("object")
