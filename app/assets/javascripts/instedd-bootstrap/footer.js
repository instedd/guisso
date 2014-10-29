jQuery(function(){

  console.log(1);

var apps = [
  { id:'geochat', url:'http://geochat.instedd.org/', name:'Geochat'},
  { id:'mesh4X', url:'http://instedd.org/technologies/mesh4x/', name:'Mesh4X'},
  { id:'nuntium', url:'http://nuntium.instedd.org/', name:'Nuntium'},
  { id:'localGateway', url:'http://instedd.org/', name:'Local Gateway'},
  { id:'pollit', url:'http://pollit.instedd.org/', name:'Pollit'},
  { id:'remindem', url:'http://remindem.instedd.org/', name:'Remindem'},
  { id:'reportingWheel', url:'http://reportingwheel.instedd.org/', name:'Reporting Wheel'},
  { id:'resourceMap', url:'http://resourcemap.instedd.org/', name:'Resource Map'},
  { id:'riff', url:'http://riff.instedd.org/', name:'Riff'},
  { id:'seentags', url:'http://seentags.instedd.org/', name:'Seentags'},
  { id:'taskMeUp', url:'http://taskmeup.instedd.org/', name:'Task Me Up'},
  { id:'veegilo', url:'http://veegilo.instedd.org/', name:'Veegilo'},
  { id:'verboice', url:'http://verboice.instedd.org/', name:'Verboice'},
  { id:'mbuilder', url:'http://mbuilder.instedd.org/', name:'Mbuilder'}
];

$.each(apps, function(index, app){
  $("#instedd_apps_icon_list").append($("<li>").attr('id',app.id)
    .append($("<a>").attr('href',app.url).attr('target','_blank').append($("<div>").text(app.name)))
  );

});

});
