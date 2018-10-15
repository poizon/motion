from PIL import Image
import face_recognition
import os

capture_folder = '/home/pavel/bitbucket/motion/capture/'

files = [f for f in os.listdir(capture_folder) if f.endswith('.jpg')]

for f in files:
    image = face_recognition.load_image_file(capture_folder + f )
    face_locations = face_recognition.face_locations(image)
    if(len(face_locations)):
        print("File: " + f + " has faces")
        for face_location in face_locations:
            top, right, bottom, left = face_location    
            print("A face is located at pixel location Top: {}, Left: {}, Bottom: {}, Right: {}".format(top, left, bottom, right))
    else:
        print("File: " + f + " has no faces")
    # You can access the actual face itself like this:
    #face_image = image[top:bottom, left:right]
    #pil_image = Image.fromarray(face_image)
    #pil_image.show()
