window.Fluxxor = require 'fluxxor'
EventEmitter = require('events').EventEmitter

constants =
  ADD_TODO: "ADD_TODO",
  TOGGLE_TODO: "TOGGLE_TODO",
  CLEAR_TODOS: "CLEAR_TODOS"

TodoStore = Fluxxor.createStore
  initialize: ->
    @todos = [];
    @bindActions(
      constants.ADD_TODO, @onAddTodo
      constants.TOGGLE_TODO, @onToggleTodo
      constants.CLEAR_TODOS, @onClearTodos
    )

  onAddTodo: (payload) ->
    @todos.push({text: payload.text, complete: false});
    @emit("change");

  onToggleTodo: (payload) ->
    payload.todo.complete = !payload.todo.complete;
    @emit("change");

  onClearTodos: ->
    @todos = @todos.filter (todo) => not todo.complete
    @emit("change")

  getState: ->
    todos: @todos

actions =
  addTodo: (text)->
    @dispatch(constants.ADD_TODO, {text: text});

  toggleTodo: (todo) ->
    @dispatch(constants.TOGGLE_TODO, {todo: todo})
  clearTodos: ->
    @dispatch(constants.CLEAR_TODOS)

stores =
  TodoStore: new TodoStore()

window.addEventListener 'load', ->
  flux = new Fluxxor.Flux(stores, actions)
  flux.on "dispatch", (type, payload) ->
    console.log type, payload
