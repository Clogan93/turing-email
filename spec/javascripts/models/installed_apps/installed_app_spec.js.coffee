describe "InstalledApp", ->
  describe "#CreateFromJSON", ->
    describe "InstalledPanelApp", ->
      beforeEach ->
        installedAppJSON = FactoryGirl.create("InstalledPanelApp")
        @installedPanelApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
        
      it "creates the InstalledPanelApp", ->
        expect(@installedPanelApp instanceof TuringEmailApp.Models.InstalledApps.InstalledPanelApp).toBeTruthy()