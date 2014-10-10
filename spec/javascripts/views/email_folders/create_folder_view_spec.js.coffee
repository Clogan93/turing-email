describe "CreateFolderView", ->
  beforeEach ->
    specStartTuringEmailApp()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(TuringEmailApp.views.createFolderView.template).toEqual JST["backbone/templates/email_folders/create_folder"]

  describe "after render", ->
    beforeEach ->
      TuringEmailApp.views.createFolderView.render()

    describe "#render", ->
      
      it "calls setupCreateFolderView", ->
        spy = sinon.spy(TuringEmailApp.views.createFolderView, "setupCreateFolderView")
        TuringEmailApp.views.createFolderView.render()
        expect(spy).toHaveBeenCalled()

    describe "#setupCreateFolderView", ->

      it "binds the submit event to .createFolderForm", ->
        expect(TuringEmailApp.views.createFolderView.$el.find(".createFolderForm")).toHandle("submit")

      describe "when the create folder form is submitted", ->
        beforeEach ->
          TuringEmailApp.views.createFolderView.folderType = "label"

        it "triggers createFolderFormSubmitted", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.createFolderView, "createFolderFormSubmitted")
          TuringEmailApp.views.createFolderView.$el.find(".createFolderForm").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "hides the create folder modal", ->
          spy = sinon.spy(TuringEmailApp.views.createFolderView, "hide")
          TuringEmailApp.views.createFolderView.$el.find(".createFolderForm").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#show", ->

      it "shows the create folder modal", ->
        TuringEmailApp.views.createFolderView.show()
        expect($("body")).toContain(".modal-backdrop.fade.in")

    describe "#hide", ->

      it "hides the create folder modal", ->
        TuringEmailApp.views.createFolderView.hide()
        expect(TuringEmailApp.views.createFolderView.$el.find(".createFolderModal").hasClass("in")).toBeFalsy()
