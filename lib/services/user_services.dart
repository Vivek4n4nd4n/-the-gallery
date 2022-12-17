import 'package:thegallery/db_helper/repositary.dart';
import 'package:thegallery/media_model.dart';

class MediaService{
  late Repository _repository;
  MediaService(){
    _repository = Repository();

  }
  saveMedia(Media media)async{
    return await _repository.insertData("media", media.mediaMap());
  }

  readAllMedia()async{
return await _repository.readData('media');

  }
    //Edit media
  updateMedia(Media media) async{
    return await _repository.updateData('media', media.mediaMap());
  }

  deleteMedia(mediaId) async {
    return await _repository.deleteDataById('media', mediaId);
}
}