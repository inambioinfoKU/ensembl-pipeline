package pathsteps.control;
import pathsteps.common.*;
import pathsteps.model.*;
import pathsteps.gui.*;
import java.util.*;

/**
 * When the user types into the db-change field, the databases in the dropdown
 * should be blanked out: this is what this action does.
**/
public class SetLayoutConfigurationAction extends AAction{
  public SetLayoutConfigurationAction(AEventHandler eventHandler){
    super(eventHandler);
  }
  
  protected void doAction(AView view, AModel aModel){
    PathStepsModel model = (PathStepsModel)aModel;
    Properties history = view.getApplication().getHistory();
    ModelElement dialogModel = model.getRootElement().getChildElement(model.LAYOUT_DIALOG);

    String iterates;
    String springNaturalLength;
    String repulsionMultiple;
    String verticalSpacing;
    String horizontalSpacing;
    String movementLimit;
    String gravity;

    iterates = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_ITERATES);
    validateNumber(
      iterates,
      "Number of iterates is not a valid number"
    );
    
    springNaturalLength = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_SPRING_NATURAL_LENGTH);
    validateNumber(
      springNaturalLength,
      "Spring natural length is not a valid number"
    );
    
    repulsionMultiple = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_REPULSION_MULTIPLIER);
    validateNumber(
      repulsionMultiple,
      "Repulsion multiple is not a valid number"
    );
    
    verticalSpacing = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_VERTICAL_SPACING);
    validateNumber(
      verticalSpacing,
      "Vertical Spacing is not a valid number"
    );

    horizontalSpacing = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_HORIZONTAL_SPACING);
    validateNumber(
      horizontalSpacing,
      "Horizontal Spacing is not a valid number"
    );
    
    movementLimit = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_MOVEMENT_LIMIT);
    validateNumber(
      movementLimit,
      "Movement Limit is not a valid number"
    );

    gravity = (String)dialogModel.getProperty(model.LAYOUT_DIALOG_GRAVITY);
    validateNumber(
      gravity,
      "Movement Limit is not a valid number"
    );

    dialogModel.addProperty(model.LAYOUT_DIALOG_ITERATES, iterates);
    dialogModel.addProperty(model.LAYOUT_DIALOG_SPRING_NATURAL_LENGTH, springNaturalLength);
    dialogModel.addProperty(model.LAYOUT_DIALOG_REPULSION_MULTIPLIER, repulsionMultiple);
    dialogModel.addProperty(model.LAYOUT_DIALOG_VERTICAL_SPACING, verticalSpacing);
    dialogModel.addProperty(model.LAYOUT_DIALOG_HORIZONTAL_SPACING, horizontalSpacing);
    dialogModel.addProperty(model.LAYOUT_DIALOG_MOVEMENT_LIMIT, movementLimit);
    dialogModel.addProperty(model.LAYOUT_DIALOG_GRAVITY, gravity);
    
    history.setProperty(model.LAYOUT_DIALOG_ITERATES, iterates);
    history.setProperty(model.LAYOUT_DIALOG_SPRING_NATURAL_LENGTH, springNaturalLength);
    history.setProperty(model.LAYOUT_DIALOG_REPULSION_MULTIPLIER, repulsionMultiple);
    history.setProperty(model.LAYOUT_DIALOG_VERTICAL_SPACING, verticalSpacing);
    history.setProperty(model.LAYOUT_DIALOG_HORIZONTAL_SPACING, horizontalSpacing);
    history.setProperty(model.LAYOUT_DIALOG_MOVEMENT_LIMIT, movementLimit);
    history.setProperty(model.LAYOUT_DIALOG_GRAVITY, gravity);
    
    if(getLogger().isLoggingMedium()){
      getLogger().logMedium("Added layout dialog paramters to history - writing history "+history);
    }
    
    view.getApplication().writeHistory(history);
    
    view.closeLayoutConfigurationDialog();
  }
  
  private void validateNumber(String input, String message){
    try{
      Double.parseDouble(input);
    }catch(NumberFormatException exception){
      throw new NonFatalAException(message, exception);
    }
  }
}