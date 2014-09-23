function PlatformRelation(a, b, arc, dot) {

		var self = this;
		var _a;
		var _b;
		var _span;
		var _count;
		var _arc;
		var _dot;

		function init(a, b, arc, dot) {
			_a = a;
			_b = b;
			_arc = arc;
			_dot = dot;
			_count = 0;
		}

		self.includes = function(app) {
			return _a == app || _b == app;
		}

		self.a = function() {
			return _a;
		}

		self.b = function() {
			return _b;
		}

		self.span = function(value) {
			if(!arguments.length) {
				return _span;
			} else {
				_span = value;
			}
		}

		self.increase = function() {
			_count++;
		}
		
		self.decrease = function() {
			_count--;
		}

		self.count = function(value) {
			if(!arguments.length) {
				return _count;
			} else {
				_count = value;
			}
		}

		self.arc = function(value) {
			if(!arguments.length) {
				return _arc;
			} else {
				_arc = value;
			}
		}

		self.dot = function(value) {
			if(!arguments.length) {
				return _dot;
			} else {
				_dot = value;
			}
		}

		init(a, b, arc, dot);
}