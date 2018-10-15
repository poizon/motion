from PIL import Image
import face_recognition
import os
from shutil import move
from pprint import pprint

capture_folder = '/home/pavel/bitbucket/motion/capture/'
# TODO: save known_people in SQL (SQLite db) for fast detect 
#known_people_folder = '/home/pavel/bitbucket/motion/known_people/'

files = [f for f in os.listdir(capture_folder) if f.endswith('.jpg')]
#known_pic = [f for f in os.listdir(known_people_folder) if f.endswith('.jpg')]
known_faces = []

for f in files:
    image = face_recognition.load_image_file(capture_folder + f )
    face_locations = face_recognition.face_locations(image)
    if(len(face_locations)):
        # added to known peoples
        known_faces.append(face_recognition.face_encodings(image))
        print("File: " + f + " has faces")
        # if we find image in known - we not append to db
        #move(capture_folder + f, known_people_folder + f)
        for face_location in face_locations:
            top, right, bottom, left = face_location    
            print("A face is located at pixel location Top: {}, Left: {}, Bottom: {}, Right: {}".format(top, left, bottom, right))

print("FINISHED")
pprint(known_faces)
#   print("Encodings: " + face for face in face_encodings)
#   results = face_recognition.compare_faces(known_faces, unknown_face_encoding)
