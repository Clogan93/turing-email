describe "WebsitePreviewView", ->
  beforeEach ->
    websitePreviewAttributes = FactoryGirl.create("WebsitePreview")
    @websitePreview = new TuringEmailApp.Models.WebsitePreview(websitePreviewAttributes,
      urlSuffix: websitePreviewAttributes.url
    )

    @websitePreviewView = new TuringEmailApp.Views.App.WebsitePreviewView(
      model: @websitePreview
    )

  it "has the right template", ->
    expect(@websitePreviewView.template).toEqual JST["backbone/templates/app/compose/website_preview"]

  describe "after render", ->
    beforeEach ->
      @websitePreviewView.render()

    describe "#render", ->
      
      it "sets up a hide event on the close link", ->
        expect(@websitePreviewView.$el.find(".compose_link_preview_close_button")).toHandle("click")

      describe "#attributes", ->

        attributes = ["title", "snippet", "imageUrl"]

        for attribute in attributes
          it "renders the " + attribute + " attribute", ->
            expect(@websitePreviewView.$el).toContainHtml @websitePreviewView.model.get(attribute)

      describe "when the close link is clicked", ->
        
        it "hides the preview", ->
          @spy = sinon.spy(@websitePreviewView, "hide")
          
          @websitePreviewView.$el.find(".compose_link_preview_close_button").click()
          
          expect(@spy).toHaveBeenCalled()
          @spy.restore()

    describe "#hide", ->

      it "removes the preview", ->
        removeSpy = sinon.spy($.prototype, "remove")
        @websitePreviewView.hide()
        expect(removeSpy).toHaveBeenCalled()
        removeSpy.restore()
