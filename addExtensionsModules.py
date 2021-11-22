def _settingsList(settings, key, convertToAbsolutePaths=False):
  # Return a settings value as a list (even if empty or a single value)

  value = settings.value(key)
  if value is None:
    return []
  if isinstance(value, str):
    value = [value]

  if convertToAbsolutePaths:
    absolutePaths = []
    for path in value:
      absolutePaths.append(slicer.app.toSlicerHomeAbsolutePath(path))
    return absolutePaths
  else:
    return value


settings = slicer.app.revisionUserSettings()
rawSearchPaths = list(_settingsList(settings, "Modules/AdditionalPaths",
  convertToAbsolutePaths=True))

modulesToLoadPaths = ['/home/docker/slicer/SlicerWeb/WebServer']

for modulePath in modulesToLoadPaths:
  rawSearchPaths.append(modulePath)

settings.setValue("Modules/AdditionalPaths",
  slicer.app.toSlicerHomeRelativePaths(rawSearchPaths))

import sys
sys.exit(0)


