# import gmplot package
import gmplot
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use a service account
cred = credentials.Certificate(
    r'C:\Users\skukr\Downloads\sihhackathon-99c65-firebase-adminsdk-jggbr-4dc0ace0d6.json')
firebase_admin.initialize_app(cred)

db = firestore.client()
docs = db.collection(u'accident').stream()
latitude_list = []
longitude_list = []

for doc in docs:
    doc = doc.to_dict()
    latitude_list.append(doc['Latitude'])
    longitude_list.append(doc['Longitude'])


gmap3 = gmplot.GoogleMapPlotter(18.45747,
                                73.85, 13)

# scatter method of map object
# scatter points on the google map
gmap3.scatter(latitude_list, longitude_list, '#ff0000',
              size=40, marker=False)

# Plot method Draw a line in
# between given coordinates
gmap3.apikey = "AIzaSyDne1iEolZXx1fbNHTyIMpRl2dsanKKqS8"

gmap3.draw("map.html")
