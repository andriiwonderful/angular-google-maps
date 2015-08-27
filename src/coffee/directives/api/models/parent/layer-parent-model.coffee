angular.module('uiGmapgoogle-maps.directives.api.models.parent')
.factory 'uiGmapLayerParentModel', ['uiGmapBaseObject', 'uiGmapLogger', '$timeout', (BaseObject, Logger, $timeout) ->
  class LayerParentModel extends BaseObject
    constructor: (@scope, @element, @attrs, @gMap, @onLayerCreated = undefined, @$log = Logger) ->
      unless @attrs.type?
        @$log.info 'type attribute for the layer directive is mandatory. Layer creation aborted!!'
        return
      @createGoogleLayer()
      @doShow = true

      @doShow = @scope.show if angular.isDefined(@attrs.show)
      @gObject.setMap @gMap if @doShow and @gMap?
      @scope.$watch 'show', (newValue, oldValue) =>
        if newValue isnt oldValue
          @doShow = newValue
          if newValue
            @gObject.setMap @gMap
          else
            @gObject.setMap null
      , true
      @scope.$watch 'options', (newValue, oldValue) =>
        if newValue isnt oldValue
          @gObject.setOptions newValue
      , true

      @scope.$on '$destroy', => @gObject.setMap null

    createGoogleLayer: =>
      unless @attrs.options?
        @gObject = if @attrs.namespace == undefined then new google.maps[@attrs.type]()
        else new google.maps[@attrs.namespace][@attrs.type]()
      else
        @gObject = if @attrs.namespace == undefined then new google.maps[@attrs.type](@scope.options)
        else new google.maps[@attrs.namespace][@attrs.type](@scope.options)

      if @gObject?
        @gObject.setMap @gMap

      if @gObject? and @onLayerCreated?
        @onLayerCreated(@scope, @gObject)? @gObject

  LayerParentModel
]
