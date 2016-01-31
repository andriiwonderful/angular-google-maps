###globals angular, _, google###
angular.module('uiGmapgoogle-maps.directives.api.models.parent')
.factory 'uiGmapCircleParentModel',
['uiGmapLogger', '$timeout','uiGmapGmapUtil',
'uiGmapEventsHelper', 'uiGmapCircleOptionsBuilder',
($log, $timeout, GmapUtil, EventsHelper, Builder) ->
  _settingFromDirective = (scope, fn) ->
    scope.settingFromDirective = true
    fn()
    $timeout ->
      scope.settingFromDirective = false

  class CircleParentModel extends Builder
    @include GmapUtil
    @include EventsHelper
    constructor: (scope, element, @attrs, @gMap, @DEFAULTS) ->
      @scope = scope
      lastRadius = null
      clean = =>
        lastRadius = null
        if @listeners?
          @removeEvents @listeners
          @listeners = undefined

      gObject =
        new google.maps.Circle @buildOpts GmapUtil.getCoords(scope.center), scope.radius

      @setMyOptions = (newVals, oldVals) =>
        return if scope.settingFromDirective
        unless _.isEqual(newVals,oldVals) and
        newVals == oldVals and
        (if newVals? and oldVals? then newVals.coordinates == oldVals.coordinates else true)
          gObject.setOptions @buildOpts GmapUtil.getCoords(scope.center), scope.radius

      @props = @props.concat [
        {prop: 'center',isColl: true}
        {prop: 'fill',isColl: true}
        'radius'
        'zIndex'
      ]
      @watchProps()

      if @scope.control?
        @scope.control.getCircle = ->
          gObject

      clean()
      @listeners = @setEvents(gObject, scope, scope, ['radius_changed']) or [] #or needed incase no-one is listening in controller
      @listeners.push google.maps.event.addListener gObject, 'radius_changed', ->
        ###
          possible google bug, and or because a circle has two radii
          radius_changed appears to fire twice (original and new) which is not too helpful
          therefore we will check for radius changes manually and bail out if nothing has changed
        ###

        newRadius = gObject.getRadius()
        return if newRadius == lastRadius

        lastRadius =  newRadius

        work = ->
          _settingFromDirective scope, ->
            scope.radius = newRadius if newRadius != scope.radius
            if scope.events?.radius_changed and _.isFunction scope.events?.radius_changed
              scope.events.radius_changed(gObject, 'radius_changed', scope, arguments)

        # hack
        # for some reason in specs I can not get $evalAsync to fire.. im tired of wasting time on this
        if not angular.mock
          scope.$evalAsync ->
            work()
        else
          work()

      @listeners.push google.maps.event.addListener gObject, 'center_changed', ->
        scope.$evalAsync ->
          _settingFromDirective scope, ->
            if angular.isDefined(scope.center.type)
              scope.center.coordinates[1] = gObject.getCenter().lat()
              scope.center.coordinates[0] = gObject.getCenter().lng()
            else
              scope.center.latitude = gObject.getCenter().lat()
              scope.center.longitude = gObject.getCenter().lng()


      scope.$on '$destroy', ->
        clean()
        gObject.setMap null

      $log.info @
]
