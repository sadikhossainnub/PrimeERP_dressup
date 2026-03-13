class WorkflowModel {
  final String name;
  final String documentType;
  final String workflowStateField;
  final List<WorkflowStateModel> states;
  final List<WorkflowTransitionModel> transitions;

  const WorkflowModel({
    required this.name,
    required this.documentType,
    required this.workflowStateField,
    required this.states,
    required this.transitions,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      name: json['name'] as String,
      documentType: json['document_type'] as String,
      workflowStateField: json['workflow_state_field'] as String? ?? 'workflow_state',
      states: (json['states'] as List<dynamic>?)
              ?.map((e) => WorkflowStateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transitions: (json['transitions'] as List<dynamic>?)
              ?.map((e) => WorkflowTransitionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'document_type': documentType,
      'workflow_state_field': workflowStateField,
      'states': states.map((e) => e.toJson()).toList(),
      'transitions': transitions.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkflowStateModel {
  final String state;
  final String docStatus;
  final int allowEdit;

  const WorkflowStateModel({
    required this.state,
    required this.docStatus,
    this.allowEdit = 0,
  });

  factory WorkflowStateModel.fromJson(Map<String, dynamic> json) {
    return WorkflowStateModel(
      state: json['state'] as String,
      docStatus: json['doc_status']?.toString() ?? '0',
      allowEdit: json['allow_edit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'doc_status': docStatus,
      'allow_edit': allowEdit,
    };
  }
}

class WorkflowTransitionModel {
  final String state;
  final String action;
  final String nextState;
  final String allowed;

  const WorkflowTransitionModel({
    required this.state,
    required this.action,
    required this.nextState,
    required this.allowed,
  });

  factory WorkflowTransitionModel.fromJson(Map<String, dynamic> json) {
    return WorkflowTransitionModel(
      state: json['state'] as String,
      action: json['action'] as String? ?? '',
      nextState: json['next_state'] as String? ?? '',
      allowed: json['allowed'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'action': action,
      'next_state': nextState,
      'allowed': allowed,
    };
  }
}
