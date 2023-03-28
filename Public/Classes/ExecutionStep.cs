using System.Management.Automation;

namespace PS.Automation.Helper
{
  public class ExecutionStep
  {

    /// <summary>
    /// Description of the step.
    /// </summary>
    public string StepDescription { get; set; }

    /// <summary>
    /// ScriptBlock containing the code to be executed.
    /// </summary>
    public ScriptBlock ExecutionAction { get; set; }

    /// <summary>
    /// Message to be displayed in case of failure during the execution.
    /// </summary>
    public string ErrorMsg { get; set; }

    /// <summary>
    /// Code to undo the changes made by <c>ExecutionAction</c>.
    /// </summary>
    public ScriptBlock RecoverAction { get; set; }

    /// <summary>
    /// If set, statement returning a boolean to be run before executing ExecutionAction.
    /// ExecutionAction will not be run if the statement returns False
    /// but will run if this Property is Null.
    /// </summary>
    public ScriptBlock Precondition { get; set; }

    /// <summary>
    /// Indicates whether this is a terminal error causing all previous
    /// steps to be undone
    /// </summary>
    public bool TerminalError { get; set; }

    /// <summary>
    /// Indicates wether this step has been executed.
    /// </summary>
    public bool Executed { get; set; }

    /// <summary>
    /// Indicates wether the execution was run successfully.
    /// If step is skipped, this Property defaults to True.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Object containing the error during execution.
    /// </summary>
    public object ExecutionError { get; set; }

    /// <summary>
    /// Indicates wether the step has been recovered.
    /// </summary>
    public bool Recovered { get; set; }
    public ExecutionStep()
    {

    }

    public ExecutionStep(string stepDescription, ScriptBlock ExecutionAction, ScriptBlock precondition, string errorMsg, ScriptBlock recoverAction, bool terminalError)
    {
      this.StepDescription = stepDescription;
      this.ExecutionAction = ExecutionAction;
      this.ErrorMsg = errorMsg;
      this.Precondition = precondition;
      this.RecoverAction = recoverAction;
      this.Executed = false;
      this.TerminalError = terminalError;
    }
  }
}
