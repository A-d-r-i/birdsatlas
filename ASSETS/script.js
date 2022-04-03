jQuery(document).ready(main)

function main() {
	var newMap = L.map('map').setView([46.5,2], 6);
	L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
		attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors | <a href="https://github.com/A-d-r-i/birdsatlas">A-d-r-i</a>'
	}).addTo(newMap);
	
	// loading GeoJSON file
	$.getJSON("maillesfr.geojson",function(data){
		// L.geoJson function is used to parse geojson file and load on to map
		// add GeoJSON layer to the map once the file is loaded
		var datalayer = L.geoJson(data, {
			
			onEachFeature: function(feature, featureLayer) {
				//featureLayer.bindPopup(feature.properties.maille);
				
				featureLayer.on('click', function() {
					document.getElementById('details').style.display = "block";
					document.getElementById('tuto').style.display = "none";
					var area_name = feature.properties.area_name;
					var maille = document.getElementById('maille');
					maille.textContent = feature.properties.maille;
					var area_id = document.getElementById('area_id');
					area_id.textContent = feature.properties.id;
					document.getElementById("area_name_url").setAttribute("href","https://oiseauxdefrance.org/prospecting?area=" + feature.properties.area_name + "&type=ATLAS_GRID");
					document.getElementById("area_species_2019").setAttribute("src","./SPECIES/2019/TXT/SPECIES-2019-" + feature.properties.area_name + ".txt");
					document.getElementById("area_species_never").setAttribute("src","./SPECIES/LIST/SPECIES-BLANKS-" + feature.properties.area_name + ".txt");
					document.getElementById("area_species_nf").setAttribute("src","./SPECIES/LIST/SPECIES-NF-" + feature.properties.area_name + ".txt");
				});
				
				featureLayer.setStyle({
					weight: 1,
					opacity: 0.5,
					color: 'red',
					dashArray: '3',
					fillOpacity: 0,	
				});
				
			}
		}).addTo(newMap);
		newMap.fitBounds(datalayer.getBounds());
		L.control.locate().addTo(newMap);
		//L.control.search().addTo(newMap);
		
		newMap.addControl( new L.Control.Search({
			url: 'https://nominatim.openstreetmap.org/search?format=json&q={s}',
			jsonpParam: 'json_callback',
			propertyName: 'display_name',
			propertyLoc: ['lat','lon'],
			marker: L.circleMarker([0,0],{radius:30}),
			autoCollapse: true,
			autoType: false,
			minLength: 2
		}) );
		
		
		
	});
}

