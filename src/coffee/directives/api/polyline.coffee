###global angular###
angular.module('uiGmapgoogle-maps.directives.api')
.factory 'uiGmapPolyline', [
  'uiGmapIPolyline', '$timeout', 'uiGmapPolylineChildModel',
  (IPolyline, $timeout, PolylineChildModel) ->
    class Polyline extends IPolyline
      link: (scope, element, attrs, mapCtrl) =>
        # Wrap polyline initialization inside a $timeout() call to make sure the map is created already
        IPolyline.mapPromise(scope, mapCtrl).then (gMap) =>
          # Validate required properties
          if angular.isUndefined(scope.path) or scope.path is null or not @validatePath(scope.path)
            @$log.warn 'polyline: no valid path attribute found'

          new PolylineChildModel {scope, attrs, gMap, defaults: @DEFAULTS}
]
