function PlatformApp(id, name, icon, dot) {

	var self = this;
	var _id;
	var _name;
	var _icon;
	var _index;
	var _x;
	var _y;
	var _dot;

	function init(id, name, icon, dot) {
		_id = id;
		_name = name;
		_icon = icon;
		_dot = dot;
	}

	self.id = function() {
		return _id;
	}

	self.name = function() {
		return _name;
	}

	self.icon = function() {
		return _icon;
	}

	self.index = function(value) {
		if(!arguments.length) {
			return _index;
		} else {
			_index = value;
		}
	}

	self.x = function(value) {
		if(!arguments.length) {
			return _x;
		} else {
			_x = value;
		}
	}

	self.y = function(value) {
		if(!arguments.length) {
			return _y;
		} else {
			_y = value;
		}
	}

	self.dot = function(value) {
		if(!arguments.length) {
			return _dot;
		} else {
			_dot = value;
		}
	}

	init(id, name, icon, dot);
}