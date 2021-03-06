FM.Folder = Ember.Object.extend
  files: null
  childIds: null
  parents: null
  isFotomoo: false

  init: () ->
    @_super()
    @set('parents', []) unless @get('parents')
    @set('files', []) unless @get('files')
    @set('childIds', []) unless @get('childIds')

  children: (->
    @get('childIds').map (id) -> FM.Folder.find(id)
  ).property('childIds.@each')

  parentObj: (->
    @get('parents').map (parent_ref) ->
      id = if parent_ref.isRoot then 'root' else parent_ref.id
      FM.Folder.find(id)
  ).property('parents', 'parents.[]', 'parents.@each.id')


  allChildrenFiles: ( ->
    list = []
    list.addObjects(@get('files'))
    @get('children').forEach (child) -> list.addObjects(child.get('allChildrenFiles'))
    list
  ).property('children.@each', 'files.@each', 'children.@each.allChildrenFiles')

  allChildrenUnprocessedFiles: ( ->
    @get('allChildrenFiles').filterProperty('isFotomoo', false)
  ).property('allChildrenFiles', 'allChildrenFiles.@each.isFotomoo')

  allChildrenManagedFiles: ( ->
    @get('allChildrenFiles').filterProperty('isFotomoo', true)
  ).property('allChildrenFiles', 'allChildrenFiles.@each.isFotomoo')

  allChildrenSelectedDirtyFiles: ( ->
    @get('allChildrenFiles').filter (file) ->
      file.get('selected') and (file.get('dirty') or file.get('address.dirty'))
  ).property('allChildrenFiles', 'allChildrenFiles.@each.isFotomoo')

  allChildrenSelectedFiles: ( ->
    @get('allChildrenFiles').filterProperty('selected', true)
  ).property('allChildrenFiles', 'allChildrenFiles.@each.selected')

  childrenWithUnprocessedFiles: ( ->
    @get('children').filter (e) -> e.get('allChildrenUnprocessedFiles.length')
  ).property('allChildrenUnprocessedFiles', 'children.@each')

  unprocessedFiles: ( ->
    @get('files').filterProperty('isFotomoo', false)
  ).property('files.@each.isFotomoo')

  selectedFiles: ( ->
    @get('files').filterProperty('selected', true)
  ).property('files','files.@each.selected')

  isAllSelected: (->
    @get('selectedFiles.length') == @get('unprocessedFiles.length')
  ).property('selectedFiles.length','unprocessedFiles.length')

  folderPath: (->
    full_name = [@get('title')]
    parent_ref = @.get('parents.0')
    while parent_ref and not parent_ref?.isRoot
      parent = FM.Folder.find(parent_ref.id)
      full_name.unshift(parent.get('title'))
      parent_ref = parent.get('parents.0')

    full_name
  ).property('parents')


  flatChildren: (->
    list = []
    if @get('allChildrenUnprocessedFiles.length')
      list.addObject(@)
      @get('children').forEach (child) -> list.addObjects(child.get('flatChildren'))
    list
  ).property('children.@each')


FM.Folder.reopenClass
  find: (fid) -> FM.drive.findFolder(fid)
