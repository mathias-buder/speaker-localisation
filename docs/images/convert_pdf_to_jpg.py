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
    img_file_path = os.path.dirname(files[i]) + os.sep + Path(files[i]).stem + '_' + str(i) + '.jpg'
    
    images[0].save(img_file_path, 'JPEG')
    print('Saved to: ' + img_file_path )
