@ngGmapModule "directives.api.models.parent", ->
    class @LayerParentModel extends oo.BaseObject
        constructor: (@scope, @element, @attrs, @mapCtrl, @$timeout, @onLayerCreated = undefined, @$log = directives.api.utils.Logger) ->
            unless @attrs.type?
                @$log.info("type attribute for the layer directive is mandatory. Layer creation aborted!!")
                return
            @createGoogleLayer()
            @gMap = undefined
            @doShow = true

            @$timeout =>
                @gMap = mapCtrl.getMap()
                @doShow = @scope.show  if angular.isDefined(@attrs.show)
                @layer.setMap @gMap  if @doShow isnt null and @doShow and @Map isnt null
                @scope.$watch("show", (newValue, oldValue) =>
                    if newValue isnt oldValue
                        @doShow = newValue
                        if newValue
                            @layer.setMap @gMap
                        else
                            @layer.setMap null
                , true)
                @scope.$watch("options", (newValue, oldValue) =>
                    if newValue isnt oldValue
                        @layer.setMap null
                        @layer = null
                        @createGoogleLayer()
                , true)
                @scope.$on "$destroy", ->
                    @layer.setMap null

        createGoogleLayer: ()=>
            if @attrs.options?
                @layer = if @attrs.namespace == undefined then new google.maps[@attrs.type]()
                else new google.maps[@attrs.namespace][@attrs.type]()
            else
                @layer = if@attrs.namespace == undefined then new google.maps[@attrs.type](@scope.options)
                else new google.maps[@attrs.namespace][@attrs.type](@scope.options)

            @$timeout =>
                if @layer? and @onLayerCreated?
                    @onLayerCreated(@layer)
