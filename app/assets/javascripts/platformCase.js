function PlatformCase(id, relations) {

		var self = this;
		var _id;
		var _relations;

		function init(id, relations) {
			_id = id;
			_relations = relations.slice(0);
		}

		self.id = function() {
			return _id;
		}

		self.relations = function() {
			return _relations.slice(0);
		}

		init(id, relations);
}