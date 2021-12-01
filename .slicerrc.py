slicer.util.selectModule("WebServer")
slicer.app.processEvents()
import SampleData
volume = SampleData.SampleDataLogic().downloadCTChest()

