describe 'uiGmapCircle', ->
  allDone =  undefined
  GCircle = null
  modelClicked = false

  afterEach ->
    GCircle.resetInstances()
    modelClicked = false

  beforeEach ->

    @html = """
      <ui-gmap-google-map draggable="true" center="map.center" zoom="map.zoom">
          <ui-gmap-circle center='map.circle.center'
                        radius='map.circle.radius'
                        fill='map.circle.fill'
                        stroke='map.circle.stroke'
                        clickable='map.circle.clickable'
                        draggable='map.circle.draggable'
                        editable='map.circle.editable'
                        visible='map.circle.visible'
                        events='map.circle.events'>
        </ui-gmap-circle>
      </ui-gmap-google-map>
    """
    @map =
      zoom: 12
      center : {longitude: 47, latitude: -27}

    @circle =
      id: 1,
      center: {longitude: 47, latitude: -27},
      radius: 500,
      stroke:
        color: '#08B21F',
        weight: 2,
        opacity: 1
      fill:
        color: '#08B21F',
        opacity: 0.5
      geodesic: true
      draggable: true
      clickable: true
      editable: true
      visible: true
      events:
        radius_changed: (gObject) ->


    apiMock = window['uiGmapInitiator'].initMock().apiMock
    GCircle = window.google.maps.Circle

    inject (_$rootScope_, $timeout, $browser, $compile, uiGmapCircle) =>
        @compile = $compile
        @subject = uiGmapCircle
        @browser = $browser
        @rootScope = _$rootScope_
        @timeout = $timeout

  describe 'should add one circle',  ->
    it 'from start', (done) ->
      scope = @rootScope.$new()
      @map.circle = @circle
      _.extend scope, map: @map

      element = @compile(@html)(scope)
      @digest =>
        @timeout =>
          expect(GCircle.instances).toEqual(1)
          done()

  describe 'events', ->
    it 'call radius changed once', (done) ->
      scope = @rootScope.$new()

      @circle.events =
        radius_changed: ->

      _spy = spyOn @circle.events, 'radius_changed'

      @map.circle = @circle
      _.extend scope, map: @map

      element = @compile(@html)(scope)

      listener = GCircle.creationSubscribe @, (gObject) =>
        _.delay =>
          window.google.maps.event.fireListener(gObject,'radius_changed')
          expect(@circle.events.radius_changed).toHaveBeenCalled()
          expect(@circle.events.radius_changed.calls.count()).toBe(1)
          done()

      @digest =>
        @timeout =>
          expect(GCircle.instances).toEqual(1)
          GCircle.creationUnSubscribe listener
        , 500

  it 'exists', ->
    expect(@subject).toBeDefined()
