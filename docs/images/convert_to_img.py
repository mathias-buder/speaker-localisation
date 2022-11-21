# import module
from pdf2image import convert_from_path
import os
from pathlib import Path

search_path = os.path.dirname(__file__)
sarch_file_extension = '.pdf'

print("Searching in " + search_path + " for " + sarch_file_extension + " files")

files = []
# r=root, d=directories, f = files
for r, d, f in os.walk(search_path):
    for file in f:
        if sarch_file_extension in file:
            files.append(os.path.join(r, file))

print("Found " + str(len(files)) + " " + sarch_file_extension + " files")

for i in range(len(files)):
    print('[' + str(i + 1) + ']' + ' Converting ' + files[i])
    # Store Pdf with convert_from_path function
    images = convert_from_path(files[i])
    # images.save('page'+ str(i) +'.jpg', 'JPEG')