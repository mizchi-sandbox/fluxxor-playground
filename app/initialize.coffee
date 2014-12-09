Fluxxor = require 'fluxxor'
EventEmitter = require('events').EventEmitter


# Store

constants =
  ADD_TODO: "ADD_TODO",
  TOGGLE_TODO: "TOGGLE_TODO",
  CLEAR_TODOS: "CLEAR_TODOS"

TodoStore = Fluxxor.createStore
  initialize: ->
    @todos = []
    @bindActions(
      constants.ADD_TODO, @onAddTodo
      constants.TOGGLE_TODO, @onToggleTodo
      constants.CLEAR_TODOS, @onClearTodos
    )

  onAddTodo: (payload) ->
    @todos.push({text: payload.text, complete: false})
    @emit("change")

  onToggleTodo: (payload) ->
    payload.todo.complete = !payload.todo.complete
    @emit("change")

  onClearTodos: ->
    @todos = @todos.filter (todo) => not todo.complete
    @emit("change")

  getState: ->
    todos: @todos

actions =
  addTodo: (text)->
    @dispatch(constants.ADD_TODO, {text: text})

  toggleTodo: (todo) ->
    @dispatch(constants.TOGGLE_TODO, {todo: todo})
  clearTodos: ->
    @dispatch(constants.CLEAR_TODOS)

stores =
  TodoStore: new TodoStore()

flux = new Fluxxor.Flux(stores, actions)
flux.on "dispatch", (type, payload) ->
  console.log type, payload

React = require 'react'
FluxMixin = Fluxxor.FluxMixin(React)
StoreWatchMixin = Fluxxor.StoreWatchMixin
$ = React.createElement

TodoItem = React.createClass
  mixins: [FluxMixin]
  propTypes:
    todo: React.PropTypes.object.isRequired

  render: ->
    style =
      textDecoration: if @props.todo.complete then "line-through" else ""

    $ 'span', style: style, onClick:@onClick, @props.todo.text

  onClick: ->
    @getFlux().actions.toggleTodo(@props.todo)

Application = React.createClass
  mixins: [FluxMixin, StoreWatchMixin("TodoStore")]

  getInitialState: ->
    newTodoText: ""

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store("TodoStore").getState()

  render: ->
    $ 'div', {}, [
      $ 'ul', {}, @state.todos.map (todo, i) =>
        $ 'li', key:(i+'-item'), [(TodoItem todo: todo)]

      $ 'form', onSubmit: @onSubmitForm, [
        $ 'input',
          type:"text"
          size:"30"
          placeholder:"New Todo"
          value: @state.newTodoText
          onChange:@handleTodoTextChange
        $ 'input',
          type:"submit"
          value:"Add Todo"
      ]
      $ 'button', onClick: @clearCompletedTodos, 'Clear Completed'
    ]

  handleTodoTextChange: (e) ->
    @setState newTodoText: e.target.value

  onSubmitForm: (e) ->
    e.preventDefault()
    if @state.newTodoText.trim()
      @getFlux().actions.addTodo(@state.newTodoText)
      @setState newTodoText: ""

  clearCompletedTodos: (e) ->
    @getFlux().actions.clearTodos()

window.addEventListener 'load', ->
  React.render Application(flux:flux), document.body
